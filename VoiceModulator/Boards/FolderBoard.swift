//
//  FolderVC.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/16/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

class FolderBoardContext {
    
    let type: FolderBoardType
    
    init(boardtype: FolderBoardType) {
        type = boardtype
    }
}

enum FolderBoardType {
    case `import`
    case export
}

class FolderBoard: NSViewController, NavControllerReferable {
    
    @IBOutlet weak var titleTextField: NSTextField!
    
    @IBOutlet weak var folderButton: NSButton!
    
    @IBAction func folderPressed(_ sender: AnyObject) {
        self.openFileChooser()
    }
    
    /// context that will allow user to define which type of board to use, default is Import
    fileprivate var context: FolderBoardType = .import
    
    /// reference to the NavController that may be holding this board
    weak var nav: NavController?
    
    fileprivate func openFileChooser() {
        
        nav?.disableProgression()
        
        let panel = NSOpenPanel()
        
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = folderTitle
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            
            let directory = panel.url!
            let path = directory.path
        
            setPath(path)
            updateFolderBoard(withPath: path)
        }
    }
    
    fileprivate func updateFolderBoard(withPath path: String) {
        
        if path.isEmpty || path == "/" {
            folderButton.title = "Choose Folder"
            nav?.disableProgression()
        } else {
            folderButton.title = path.lastPathComponent
            nav?.enableProgression()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startingPath = path
        titleTextField.stringValue = folderTitle
        updateFolderBoard(withPath: startingPath)
    }
    
    func setPath(_ path: String) {
        switch context {
        case .import: appDelegate.store.importPath = path
        case .export: appDelegate.store.exportPath = path
        }
    }
    
    var folderTitle: String {
        switch context {
        case .import: return "Choose Import Folder"
        case .export: return "Choose Export Folder"
        }
    }
    
    var path: String {
        switch context {
        case .import: return appDelegate.store.importPath
        case .export: return appDelegate.store.exportPath
        }
    }
    
    var progression: ProgressionType {
        switch context {
        case .import: return .next
        case .export: return .finished
        }
    }
    
    func executeProgression() {
        switch context {
        case .import:
            HGReport.shared.report("Attempting to Import", type: .error)
//            let context = SBD_Import()
//            let boarddata = SelectionBoard.boardData(withContext: context)
//            nav?.push(boarddata)
        case .export:
            appDelegate.store.exportProject()
        }
    }
}

extension FolderBoard: BoardInstantiable {
    static var storyboard: String { return "Board" }
    static var nib: String { return "FolderBoard" }
}

extension FolderBoard: BoardRetrievable {
    
    
    func contextForBoard() -> AnyObject {
        return FolderBoardContext(boardtype: context)
    }
    
    
    func set(context: AnyObject) {
        // assign context if it is of type SelectionBoardDelegate
        if let fbc = context as? FolderBoardContext {
            self.context = fbc.type;
            return
        }
        HGReport.shared.report("FolderBoard Context \(context) not valid", type: .error)
    }
}

extension FolderBoard: NavControllerProgessable {
    
    func navcontrollerProgressionType(_ nav: NavController) -> ProgressionType {
        return progression
    }
    
    func navcontroller(_ nav: NavController, hitProgressWithType progressionType: ProgressionType) {
        executeProgression()
    }
}
