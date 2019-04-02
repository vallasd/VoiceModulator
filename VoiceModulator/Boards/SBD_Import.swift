//
//  SBD_Import.swift
//  HuckleberryGen
//
//  Created by David Vallas on 1/10/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

class SBD_Import: SelectionBoardDelegate {
    
    /// intialization method
    init() {
        createImportFolder()
    }
    
    /// weak reference to the selection board
    weak var selectionBoard: SelectionBoard?
    
    /// a folder of import files
    var importFolder: Folder!
    
    /// creates a folder (of importfiles) from searchPath
    fileprivate func createImportFolder() {
        
        let path = appDelegate.store.importPath
        let name: String = path.lastPathComponent
        
        // Create a folder from path and name
        Folder.create(name: name, path: path, completion: { [weak self] (newfolder) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self?.importFolder = newfolder
                self?.selectionBoard?.update()
            })
        })
    }
    
    /// SelectionBoardDelegate function
    func selectionboard(_ sb: SelectionBoard, didChooseLocation loc: HGTableLocation) {
//        let importFile = importFolder.importFiles[loc.index]
        selectionBoard?.update()
    }
    
}

// MARK: HGTableDisplayable
extension SBD_Import: HGTableDisplayable {
    
    func numberOfItems(fortable table: HGTable) -> Int {
        return importFolder != nil ? importFolder.importFiles.count : 0
    }
    
    func cellType(fortable table: HGTable) -> CellType {
        return CellType.fieldCell3
    }
    
    func hgtable(_ table: HGTable, dataForIndex index: Int) -> HGCellData {
        let file = importFolder!.importFiles[index]
        return HGCellData.fieldCell3(
            field0: HGFieldData(title: file.name),
            field1: HGFieldData(title: "Path:"),
            field2: HGFieldData(title: file.path),
            field3: HGFieldData(title: "Last Modified:"),
            field4: HGFieldData(title: file.modificationDate.mmddyy))
    }
}

// MARK: HGTableRowSelectable
extension SBD_Import: HGTableLocationSelectable {

    func hgtable(_ table: HGTable, shouldSelectLocation loc: HGTableLocation) -> Bool {
        return true
    }
    
    func hgtable(_ table: HGTable, didSelectLocation loc: HGTableLocation) {
        // do nothing
    }
    
}
