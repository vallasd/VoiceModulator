//
//  HGTable.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/1/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa
import Foundation

/// protocol that allows user to track a selected location.  This is designed to be used by a secondary delegate to track changes made to the table.
protocol HGTableSelectionTrackable: AnyObject {
    func hgtable(_ table: HGTable, selectedLocationChangedTo: HGTableLocation)
    func hgtableLocationDeselected(_ table: HGTable)
}

/// protocol that allows HGTable to display data in rows.
protocol HGTableDisplayable: AnyObject {
    /// Pass the number of items in your model
    func numberOfItems(fortable table: HGTable) -> Int
    /// Pass the CellType for a specific row in the HGTable
    func cellType(fortable table: HGTable) -> CellType
    /// Pass the HGCellData for a specific index in your model to HGTable.  The data will be used to populate the cell appropriately. (use HGCellData builder)
    func hgtable(_ table: HGTable, dataForIndex index: Int) -> HGCellData
}

/// protocol that allows HGTable to observe notification and reload Table when a notification is sent.
protocol HGTableObservable: HGTableDisplayable {
    /// Pass the notification name that the HGTable should observe, table will reload data when the notification is observed.
    func observeNotifications(fortable table: HGTable) -> [String]
}

/// protocol that allows user to select types of the HGTableLocation in an HGTable
protocol HGTableLocationSelectable: HGTableDisplayable {
    func hgtable(_ table: HGTable, shouldSelectLocation loc: HGTableLocation) -> Bool
    func hgtable(_ table: HGTable, didSelectLocation loc: HGTableLocation)
}

/// return object for HGTablePostable delegate
struct HGTablePostableData {
    let notificationName: String
    let identifier: String // unique identifier, the receiving HGTable will update parentName with this String
}

/// protocol that allows HGTable to post a notification every time a new object is selected, will pass the selected row as an Int in the notification's object or notSelected if row was deselected.  Will also pass the tables HGTable rowIdentifier. Set this value to identify the identifier for the Set if you aren't using arrays in your HGTables.
protocol HGTablePostable: HGTableLocationSelectable {
    /// Pass the notification name that the HGTable should POST when a new row is selected.
    func postData(fortable table: HGTable, atIndex: Int) -> HGTablePostableData
}

/// protocol that allows user to edit fields of the HGCell in an HGTable
protocol HGTableFieldEditable: HGTableDisplayable {
    func hgtable(_ table: HGTable, shouldEditRow row: Int, field: Int) -> Bool
    func hgtable(_ table: HGTable, didEditRow row: Int, field: Int, withString string: String)
}

/// allows user to add and delete rows in HGTable.  Handles the table updates within HGTable, as long as Delegate updates the Datasource.
protocol HGTableRowAppendable: HGTableDisplayable {
    func hgtable(shouldAddRowToTable table: HGTable) -> Bool
    func hgtable(willAddRowToTable table: HGTable)
    func hgtable(_ table: HGTable, shouldDeleteRows rows: [Int]) -> Option
    func hgtable(_ table: HGTable, willDeleteRows rows: [Int])
}

/// HGTable is a custom class that is the NSTableViewDataSource and NSTableViewDelegate delegate for an NSTableView.  This class works with HGCell to provide generic cell templates to NSTableView. This class provides a custom interface for NSTableView so that: HGCell fields can be edited, User warnings / feedback Pop-ups display, Option Selection Pop-ups display, KeyBoard commands accepted.  The user can fine tune the HGTable by determining which of the many protocols in the class that they choose to implement.  To Properly use this class, set the delegates then the HGTableView
class HGTable: NSObject {
    
    /// initialize with a NSTableView
    init(tableview: NSTableView, delegate: HGTableDisplayable) {
        super.init()
        updateSubDelegates(withSuperDelegate: delegate)
        updateTableView(withTableView: tableview)
        addProjectChangedObserver()
    }
    
    /// initialize with a NSTableView
    init(tableview: NSTableView, delegate: HGTableDisplayable, selectionTrackingDelegate: HGTableSelectionTrackable) {
        super.init()
        updateSubDelegates(withSuperDelegate: delegate)
        updateTableView(withTableView: tableview)
        stDelegate = selectionTrackingDelegate
        addProjectChangedObserver()
    }
    
    func updateSubDelegates(withSuperDelegate delegate: HGTableDisplayable) {
        displayDelegate = delegate
        if let d = delegate as? HGTableObservable { observeDelegate = d }
        if let d = delegate as? HGTablePostable { selectDelegate = d }
        if let d = delegate as? HGTableLocationSelectable { locationSelectDelegate = d }
        if let d = delegate as? HGTableFieldEditable { fieldEditDelegate = d }
        if let d = delegate as? HGTableRowAppendable { rowAppenedDelegate = d }
    }
    
    func updateTableView(withTableView tv: NSTableView) {
        tableview = tv
        tableview.identifier = NSUserInterfaceItemIdentifier(rawValue: String.random(7))
        tableview.delegate = self
        tableview.dataSource = self
        
        // we check if the tableview is an HGTableView and if so, we assign the delegate
        if let hgtv = tableview as? HGTableView {
            hgtv.extendedDelegate = self
        }
    }
    
    fileprivate(set) var parentIndex: Int = notSelected
    fileprivate(set) var parentName: String = ""
    
    fileprivate var rowWidth: CGFloat {
        let sWidth = tableview.superview?.bounds.width
        let width = sWidth != nil ? sWidth! - 3.0 : 250.0
        return width
    }
    fileprivate var rows = 0
    fileprivate var imagesPerRow = 0
    fileprivate var didSetWidthObserver = false
    fileprivate(set) var celltype: CellType! {
        didSet {
            if celltype == .imageCell && !didSetWidthObserver {
                tableview.tableColumns.first?.addObserver(self, forKeyPath: "width", options: [.new], context: nil)
                didSetWidthObserver = true
            }
        }
    }
    fileprivate(set) var items: Int = 0
    
    // MARK: HGTable Delegates
    
    /// Delegate for AnyObject which conforms to protocol HGTableTrackable
    fileprivate weak var stDelegate: HGTableSelectionTrackable?
    
    /// weak reference to the NSTableView
    fileprivate weak var tableview: NSTableView!
    
    /// Delegate for AnyObject which conforms to protocol HGTableObservable
    fileprivate weak var observeDelegate: HGTableObservable? {
        willSet {
            HGNotif.removeObserver(self)
        }
        didSet {
            addProjectChangedObserver()
            let names = observeDelegate!.observeNotifications(fortable: self)
            addObservers(withNotifNames: names)
        }
    }
    
    /// Delegate for AnyObject which conforms to protocol HGTablePostable
    fileprivate weak var selectDelegate: HGTablePostable?
    /// Delegate for AnyObject which conforms to protocol HGTableDisplayable
    fileprivate weak var displayDelegate: HGTableDisplayable?
    /// Delegate for AnyObject which conforms to protocol HGTableLocationSelectable
    fileprivate weak var locationSelectDelegate: HGTableLocationSelectable?
    /// Delegate for AnyObject which conforms to protocol HGTableItemEditable
    fileprivate weak var fieldEditDelegate: HGTableFieldEditable?
    /// Delegate for AnyObject which conforms to protocol HGTableRowAppendable
    fileprivate weak var rowAppenedDelegate: HGTableRowAppendable?
    
    // MARK: Private Properties
    fileprivate var tableCellIdentifiers: [TableCellIdentifier] = []
    
    fileprivate(set) weak var lastSelectedCellWithTag: HGCell?
    
    /// set of locations that are currently selected on the Table (can be rows or items)
    fileprivate(set) var selectedLocation: HGTableLocation? {
        didSet {
            if selectedLocation != nil {
                stDelegate?.hgtable(self, selectedLocationChangedTo: selectedLocation!)
            } else {
                stDelegate?.hgtableLocationDeselected(self)
            }
        }
    }
    
    /// reloads tableView
    func update() {
        tableview.reloadData()
    }
    
    /// Registers HGCell's Nib with TableView one time
    fileprivate func register(_ cellType: CellType, forTableView tableView: NSTableView) {
        let tci = TableCellIdentifier(tableId: tableView.identifier.map { $0.rawValue }, cellId: cellType.identifier)
        if tableCellIdentifiers.contains(tci) { return }
        let nib = NSNib(nibNamed: NSNib.Name(cellType.identifier), bundle: nil)
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellType.identifier))
        tableCellIdentifiers.append(tci)
    }
    
    // MARK: Observers
    fileprivate func addObservers(withNotifNames names: [String]) {
        for name in names {
            HGNotif.addObserverForName(name, usingBlock: { [weak self] (notif) -> Void in
                if let dict = notif.object as? HGDICT {
                    self?.parentIndex = dict["index"].int
                    self?.parentName = dict["name"].string
                }
                self?.update()
                })
        }
    }
    
    fileprivate func addProjectChangedObserver() {
        
        let uniqueID = appDelegate.store.uniqIdentifier
        let notifType = HGNotifType.projectChanged
        let notifName = notifType.uniqString(forUniqId: uniqueID)
        
        HGNotif.addObserverForName(notifName, usingBlock: { [weak self] (notif) -> Void in
            self?.parentIndex = notSelected
            self?.parentName = ""
            self?.update()
            })
    }
    
    fileprivate func calculateImagesPerRow() -> Int {
        let ipr = celltype.imagesPerRow(rowWidth: rowWidth)
        return ipr
    }
    
    fileprivate func locationIndexFrom(row: Int, typeIndex: Int) -> Int {
        if celltype == .imageCell {
            return row * imagesPerRow + typeIndex
        }
        return row
    }
    
    fileprivate func celldata(forRow row: Int) -> HGCellData {
        
        // image cell data request, we pull more than one index at a time
        if celltype == .imageCell {
            var datas: [HGCellData] = []
            let startIndex = locationIndexFrom(row: row, typeIndex: 0)
            let endIndex = min(startIndex+imagesPerRow, items-1)
            for index in startIndex...endIndex {
                let data = displayDelegate?.hgtable(self, dataForIndex: index) ?? HGCellData.empty
                datas.append(data)
            }
            return HGCellData.combined(datas, rowCount: imagesPerRow)
        }
        
        // non imageCell data request
        return displayDelegate?.hgtable(self, dataForIndex: row) ?? HGCellData.empty
    }
    
    /// will highlight an image in cell if by using selectedLocation to determine what new cooresponding cell should be highlighted.  Use when width changes update the cells width.
    fileprivate func highlightImage(incell cell: HGCell) {
        if let s = selectedLocation, celltype == .imageCell {
            let row = cell.row
            for typeIndex in 0..<imagesPerRow {
                let currentIndex = row * imagesPerRow + typeIndex
                if currentIndex == s.index {
                    selectedLocation = HGTableLocation(index: s.index, type: s.type, typeIndex: typeIndex)
                    cell.highlight(imageIndex: typeIndex)
                    break
                }
            }
        }
    }
    
    /// we are observing width for imageCells, if imagesPerRow changes, we reload tableview.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "width" {
            let ipr = calculateImagesPerRow()
            if ipr != imagesPerRow {
                imagesPerRow = ipr
                tableview.reloadData()
            }
        }
    }
    
    // MARK: Deinit
    deinit {
        HGNotif.removeObserver(self)
        tableview?.tableColumns.first?.removeObserver(self, forKeyPath: "width")
    }
}

// MARK: NSTableViewDataSource
extension HGTable: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        celltype = displayDelegate?.cellType(fortable: self) ?? .defaultCell
        items = displayDelegate?.numberOfItems(fortable: self) ?? 0
        imagesPerRow = calculateImagesPerRow()
        register(celltype, forTableView: tableView)
        rows = celltype.numRows(rowWidth: rowWidth, items: items)
        return rows
    }
}

// MARK: NSTableViewDelegate
extension HGTable: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return celltype.rowHeight
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: celltype.identifier), owner: self) as! HGCell
        cell.delegate = self
        let data = celldata(forRow: row)
        cell.update(withRow: row, cellData: data)
        highlightImage(incell: cell)
        return cell
    }
}

// MARK: HGTableViewDelegate
extension HGTable: HGTableViewDelegate {
    
    func hgtableview(_ hgtableview: HGTableView, shouldSelectRow row: Int) -> Bool {
        let loc = HGTableLocation(index: row, type: .row, typeIndex: 0)
        return locationSelectDelegate?.hgtable(self, shouldSelectLocation: loc) ?? false
    }
    
    func hgtableview(shouldAddRowToTable hgtableview: HGTableView) -> Bool {
        return rowAppenedDelegate?.hgtable(shouldAddRowToTable: self) ?? false
    }
    
    func hgtableviewShouldDeleteSelectedRows(_ hgtableview: HGTableView) -> Bool {
        
        let rows = hgtableview.selectedRows
        let answer = rowAppenedDelegate?.hgtable(self, shouldDeleteRows: rows) ?? .no
        
        // if we are asking user, produce a Decision Board for Delete Rows
        if answer == .askUser {
            let context = DBD_DeleteRows(tableview: hgtableview, rowsToDelete: rows)
            let boardData = DecisionBoard.boardData(withContext: context)
            appDelegate.mainWindowController.boardHandler.start(withBoardData: boardData)
            return false
        }
        
        return answer == .no ? false : true
    }
    
    func hgtableview(_ hgtableview: HGTableView, didSelectRow row: Int) {
        if let postData = selectDelegate?.postData(fortable: self, atIndex: row) {
            let notification = postData.notificationName
            let name = postData.identifier
            let postObject: HGDICT = ["index" : row, "name" : name]
            HGNotif.postNotification(notification, withObject: postObject)
        }
    }
    
    func hgtableview(willAddRowToTable hgtableview: HGTableView) {
        rowAppenedDelegate?.hgtable(willAddRowToTable: self)
    }
    
    func hgtableview(_ hgtableview: HGTableView, willDeleteRows rows: [Int]) {
        rowAppenedDelegate?.hgtable(self, willDeleteRows: rows)
    }
    
    func hgtableview(_ hgtableview: HGTableView, didDeleteRows rows: [Int]) {
        if let postData = selectDelegate?.postData(fortable: self, atIndex: notSelected) {
            let notification = postData.notificationName
            let row = notSelected
            let name = ""
            let postObject: HGDICT = ["index" : row, "name" : name]
            HGNotif.postNotification(notification, withObject: postObject)
        }
    }
}

extension HGTable: HGCellDelegate {
    
    func hgcell(_ cell: HGCell, shouldSelectTypeIndex index: Int, type: HGLocationType) -> Bool {
        let locIndex = locationIndexFrom(row: cell.row, typeIndex: index)
        let loc = HGTableLocation(index: locIndex, type: type, typeIndex: index)
        return locationSelectDelegate?.hgtable(self, shouldSelectLocation: loc) ?? false
    }
    
    func hgcell(_ cell: HGCell, didSelectTypeIndex index: Int, type: HGLocationType) {
        
        let locationIndex = locationIndexFrom(row: cell.row, typeIndex: index)
        let newloc = HGTableLocation(index: locationIndex, type: type, typeIndex: index)
        var unhighlighted = false
        
        if type == .image {
            // We already have selected the location before.  Need to unselect.
            if selectedLocation == newloc {
                cell.unhighlight(imageIndex: index)
                unhighlighted = true
            } else {
                lastSelectedCellWithTag?.unhighlightImages()
                cell.highlight(imageIndex: index)
            }
        }
        
        // handle last selected cell and selected location
        if unhighlighted {
            lastSelectedCellWithTag = nil
            selectedLocation = nil
        } else {
            lastSelectedCellWithTag = cell
            selectedLocation = newloc
        }
        
        locationSelectDelegate?.hgtable(self, didSelectLocation: newloc)
    }
    
    func hgcell(_ cell: HGCell, shouldEditField field: Int) -> Bool {
        return fieldEditDelegate?.hgtable(self, shouldEditRow: cell.row, field: field) ?? false
    }
    
    func hgcell(_ cell: HGCell, didEditField field: Int, withString string: String) {
        fieldEditDelegate?.hgtable(self, didEditRow: cell.row, field: field, withString: string)
        let r = IndexSet([cell.row])
        let c = IndexSet([0])
        tableview.reloadData(forRowIndexes: r, columnIndexes: c)
    }
}
