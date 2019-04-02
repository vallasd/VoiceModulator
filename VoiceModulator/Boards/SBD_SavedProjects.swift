//
//  SBD_SavedProjects.swift
//  HuckleberryGen
//
//  Created by David Vallas on 1/12/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

/// context for a Selection Board of unique attributes
class SBD_SavedProjects: SelectionBoardDelegate {
    
    /// reference to the selection board
    weak var selectionBoard: SelectionBoard?
    
    func selectionboard(_ sb: SelectionBoard, didChooseLocation loc: HGTableLocation) {
        let _ = appDelegate.store.openProject(atIndex: loc.index)
    }
}

extension SBD_SavedProjects: HGTableDisplayable {
    
    func numberOfItems(fortable table: HGTable) -> Int {
        return appDelegate.store.savedProjects.count
    }

    func cellType(fortable table: HGTable) -> CellType {
        return CellType.fieldCell2
    }
    
    func hgtable(_ table: HGTable, dataForIndex index: Int) -> HGCellData {
        let savedProjectName = appDelegate.store.savedProjects[index]
        let fieldData = HGFieldData(title: savedProjectName)
        return HGCellData.fieldCell2(field0: fieldData, field1: HGFieldData(title: ""))
    }
}

extension SBD_SavedProjects: HGTableLocationSelectable {
    
    func hgtable(_ table: HGTable, shouldSelectLocation loc: HGTableLocation) -> Bool {
        return true
    }
    
    func hgtable(_ table: HGTable, didSelectLocation loc: HGTableLocation) {
        // do nothing
    }
}

extension SBD_SavedProjects: HGTableRowAppendable {
    
    func hgtable(shouldAddRowToTable table: HGTable) -> Bool {
        return false
    }
    
    func hgtable(willAddRowToTable table: HGTable) {
        // do nothing
    }
    
    func hgtable(_ table: HGTable, shouldDeleteRows rows: [Int]) -> Option {
        return .yes
    }
    
    func hgtable(_ table: HGTable, willDeleteRows rows: [Int]) {
        let row = rows[0]
        let _ = appDelegate.store.deleteProject(atIndex: row)
    }

}
