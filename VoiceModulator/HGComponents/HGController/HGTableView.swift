//
//  HGTableView.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/28/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

let notSelected: Int = -99

protocol HGTableViewDelegate: NSTableViewDelegate {
    func hgtableview(_ hgtableview: HGTableView, shouldSelectRow row: Int) -> Bool
    func hgtableview(shouldAddRowToTable hgtableview: HGTableView) -> Bool
    func hgtableviewShouldDeleteSelectedRows(_ hgtableview: HGTableView) -> Bool
    func hgtableview(_ hgtableview: HGTableView, didSelectRow row: Int)
    func hgtableview(willAddRowToTable hgtableview: HGTableView)
    func hgtableview(_ hgtableview: HGTableView, willDeleteRows rows: [Int])
    func hgtableview(_ hgtableview: HGTableView, didDeleteRows rows: [Int])
}

/// Extended NSTableView that appropriate handles mouse and keyboard clicks for Huckleberry Gen
class HGTableView: NSTableView {
    
    /// Determines if user can select / deselect multiple rows.  Functionality currently broken
    var allowsMultipleRowSelection: Bool = false
    
    /// Returns array of selected rows.  Do not use inside HGTableView (use iSelectedRows)
    var selectedRows: [Int] {
        get {
            return Array(iSelectedRows)
        }
    }
    
    /// A set of selected rows.  Internal Variable.
    fileprivate var iSelectedRows: NSMutableIndexSet = NSMutableIndexSet()
    
    /// Extended delegate that conforms to protocol HGTableViewDelegate
    var extendedDelegate: HGTableViewDelegate?
    
    /// Deletes rows supplied without conferring with delegate
    func delete(rows: [Int]) {
        
        // return if no rows to delete
        if rows.count == 0 {
            return
        }
        
        // create indexSet from rows
        let indexSet = NSMutableIndexSet()
        for row in rows { indexSet.add(row) }
        
        // notify delegate about impending deletion
        extendedDelegate?.hgtableview(self, willDeleteRows: rows)
        
        // remove indexes from selected rows
        iSelectedRows.remove(indexSet as IndexSet)
        
        // remove rows from self (Tableview)
        self.removeRows(at: indexSet as IndexSet, withAnimation: NSTableView.AnimationOptions())
        
        // If we were trying to remove only one row at a time, we will auto-highlight the row above so the user can easily delete out multiple rows with a command
        if rows.count == 1 {
            let row = rows[0]
            let numRows = self.numberOfRows
            if row < numRows {
                selectRow(row)
            } else if numRows > 0 {
                selectRow(numRows - 1)
            }
        }
        
        // notify delegate that deletion happened
        extendedDelegate?.hgtableview(self, didDeleteRows: rows)
    }
    
    /// custom HGTableView function that handles mouseDown events
    override func mouseDown(with theEvent: NSEvent) {
        
        let global = theEvent.locationInWindow
        let local = self.convert(global, from: nil)
        let row = self.row(at: local)
        
        if (row != notSelected && row != -1) {
            selectRow(row)
        }
    }
    
    /// custom HGTableView function that handles keyDown events
    override func keyDown(with theEvent: NSEvent) {
        let command = theEvent.command()
        switch command {
        case .addRow: addRow()
        case .deleteRow: deleteSelectedRowsIfDelegateSaysOK()
        case .nextRow: selectNext()
        case .previousRow: selectPrev()
        case .printRowInformation: printRowInformation()
        default: break // Do Nothing
        }
    }
    
    fileprivate func printRowInformation() {
        
        let indent = "   "
        HGReport.shared.report("HGTable:", type: .info)
        for row in 0..<numberOfRows {
            HGReport.shared.report("\(indent)row: \(row)", type: .info)
            let v = view(atColumn: 0, row: row, makeIfNecessary: false)
            reportDetails(view: v, indent: indent)
            HGReport.shared.report("\(indent)subviews:", type: .info)
            HGReport.shared.report("", type: .info)
            for s in v?.subviews ?? [] {
                let indent = indent + indent
                reportDetails(view: s, indent: indent)
                HGReport.shared.report("", type: .info)
            }
        }
    }
    
    fileprivate func reportDetails(view: NSView?, indent: String) {
        
        guard let v = view else {
            HGReport.shared.report("\(indent)error: no view info provide", type: .info)
            return
        }
        
        if let b = v as? NSButton {
            HGReport.shared.report("\(indent)type: button", type: .info)
            HGReport.shared.report("\(indent)title: \(b.title)", type: .info)
        }
        else if let t = v as? NSTextField {
            HGReport.shared.report("\(indent)type: textfield", type: .info)
            HGReport.shared.report("\(indent)text: \(t.stringValue)", type: .info)
        }
        else {
            HGReport.shared.report("\(indent)type: nsview", type: .info)
        }
        
        HGReport.shared.report("\(indent)bounds: \(v.bounds.info)", type: .info)
        HGReport.shared.report("\(indent)frame: \(v.frame.info)", type: .info)
    }
    
    /// custom HGTableView function that handles changed flag events such as command button held down
    override func flagsChanged(with theEvent: NSEvent) {
        let options = theEvent.commandOptions()
        if options.contains(HGCommandOptions.MultiSelectOn) {
            allowsMultipleRowSelection = true
        } else {
            allowsMultipleRowSelection = false
        }
    }
    
    /// selects or unselects (if row is currently selected) a row
    fileprivate func selectRow(_ r: Int) {
        
        var row = r
        
        if row != notSelected {
            
            let isSelectableRow = extendedDelegate?.hgtableview(self, shouldSelectRow: row) ?? false
            let isSelectedRow = iSelectedRows.contains(row)
            
            if isSelectedRow {
                iSelectedRows.remove(row)
                row = notSelected
            }
                
            else if isSelectableRow {
                if allowsMultipleRowSelection {
                    iSelectedRows.add(row)
                } else {
                    iSelectedRows = NSMutableIndexSet(index: row)
                }
            }
        }
        
        extendedDelegate?.hgtableview(self, didSelectRow: row)
        
        // Selects row and then scrolls to it
        OperationQueue.main.addOperation { [weak self] () -> Void in
            self?.selectRowIndexes(self?.iSelectedRows as IndexSet? ?? IndexSet(), byExtendingSelection: false)
            if row != notSelected {
                self?.scrollRowToVisible(row)
            }
        }
    }
    
    /// If allowsMultipleRowSelection == false, will select previous row, if allowsMultipleRowSelection == true will unselect the highest indexed row
    fileprivate func selectPrev() {
        
        var numSelected = iSelectedRows.count
        
        // If we don't have any rows in Table, we return
        if numberOfRows == 0 {
            return
        }
        
        // If we haven't selected anything yet, just select row 0
        if numSelected == 0 {
            selectRow(0)
            return
        }
        
        // determine the rows
        let sort = selectedRows.sorted()
        var lastRow = sort.last!
        let firstRow = sort.first!
        
        // if we only have one row which is first index, we want to exit immediately so we are not toggling selection of row
        if numSelected == 1 && firstRow == 0 {
            return
        }
        
        // unselect the last selected row if we are allowing multiple row selection
        if allowsMultipleRowSelection == true {
            selectRow(lastRow)
        }
        
        // unselect all if we do not allow multiple row selection
        else {
            lastRow = firstRow // since rows are deleted, we want to go with the first row to determine previous row
            unSelectAll()
            numSelected = 0
        }
        
        // if there are multiple rows still selected, we just will remove lastRow and exit
        if numSelected > 1 {
            return
        }
        
        // determine what previous row will be, this is unwrapped because we already checked iSelectedRows.count above
        let previousRow = lastRow - 1
        
        // returns if previous row is out of bounds
        if previousRow < 0 {
            return
        }
        
        // Selects previous row.
        selectRow(previousRow)
    }
    
    /// If allowsMultipleRowSelection == false, will select next row, if allowsMultipleRowSelection == true will add the next highest row to selection
    fileprivate func selectNext() {
        
        let numSelected = iSelectedRows.count
        
        // if we don't have any rows in Table, we return
        if numberOfRows == 0 {
            return
        }
        
        // if we haven't selected anything yet, just select row 0
        if numSelected == 0 {
            selectRow(0)
            return
        }
        
        // determine what next row will be, this is unwrapped because we already checked iSelectedRows.count above
        let nextRow = selectedRows.sorted().last! + 1
        
        // if we are not able to select next row, return
        if nextRow >= numberOfRows {
            return
        }
        
        // select next row.  This will always either add next row or move to next row depending on allowsMultipleRowSelection variable
        selectRow(nextRow)
    }
    
    /// Unselects all rows
    fileprivate func unSelectAll() {
        deselectAll(self)
        iSelectedRows = NSMutableIndexSet()
    }
    
    /// Asks delegate if hgtableview should add row, then adds row if delegate returns true
    fileprivate func addRow() {
        let shouldAdd = extendedDelegate?.hgtableview(shouldAddRowToTable: self) ?? false
        if shouldAdd == true {
            let index = numberOfRows
            unSelectAll()
            extendedDelegate?.hgtableview(willAddRowToTable: self)
            insertRows(at: IndexSet(integer: index), withAnimation: NSTableView.AnimationOptions())
            selectRow(index)
        }
    }
    
    /// Asks delegate if hgtableview should delete rows, then deletes row if delegate returns true
    fileprivate func deleteSelectedRowsIfDelegateSaysOK() {
        
        let shouldDelete = extendedDelegate?.hgtableviewShouldDeleteSelectedRows(self) ?? false
        
        if shouldDelete == true {
            delete(rows: selectedRows)
        }
        
    }
    
    fileprivate class func isTopView(_ view: NSView, previousView: NSView?) -> Bool {
        
        if let superView = view.superview {
            let _ = HGTableView.isTopView(superView, previousView: view)
        }
        print("Top View is \(view), Previous View \(String(describing: previousView))")
        print("Sub Views are \(view.subviews)")
        return false
    }
}
