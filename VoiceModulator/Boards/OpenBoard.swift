//
//  OpenBoard.swift
//  VoiceModulator
//
//  Created by David Vallas on 1/4/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

class OpenBoard: NSViewController, NavControllerReferable {
    
    /// reference to the NavController that may be holding this board
    weak var nav: NavController?
    
    /// holds reference to last tag pressed from button tags
    var lastTagPressed: Int = 0
    
    // MARK: Button Commands
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        displayBoardForTag(sender.tag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// displays next nav controller based on button tag
    fileprivate func displayBoardForTag(_ tag: Int) {
        switch tag {
        case 1: // New Project
            appDelegate.store.project = Project.new
            nav?.end()
        case 2: // Import Saved Project
            let boarddata = FolderBoard.boardData
            nav?.push(boarddata)
        default: break // Do Nothing
        }
    }
}

extension OpenBoard: BoardInstantiable {
    
    static var storyboard: String { return "Board" }
    static var nib: String { return "OpenBoard" }
}
