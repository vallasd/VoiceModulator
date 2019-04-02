//
//  SaveBoard.swift
//  VoiceModulator
//
//  Created by David Vallas on 1/26/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

class SaveBoard: NSViewController, NavControllerReferable {
    
    
    @IBOutlet weak var projectName: NSTextField!
    
    // reference to name of current project
    var currentProjectName = appDelegate.store.project.isNew ? "" : appDelegate.store.project.name
    
    // reference to the Nav Controller
    weak var nav: NavController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        projectName.delegate = self
        projectName.stringValue = currentProjectName
        updateProgression()
    }
    
    var projectNameAcceptable: Bool {
        
        // check requested name
        let requestedName = projectName.stringValue
        
        // name length too short
        if requestedName.count < 4 { return false }
        
        // project was previously saved and we just want to save it without changing new
        if requestedName == currentProjectName { return true }
        
        // new name is already a saved name
        if appDelegate.store.savedProjects.contains(requestedName) { return false }
        
        return true
    }
    
    func updateProgression() {
        if projectNameAcceptable {
            nav?.enableProgression()
        } else {
            nav?.disableProgression()
        }
    }
    
    func updateProjectName() {
        
        if projectName.stringValue != currentProjectName {
            let _ = appDelegate.store.changeCurrentProject(toName: projectName.stringValue)
            currentProjectName = projectName.stringValue
        } else {
            appDelegate.store.saveCurrentProject()
        }
        
        appDelegate.store.save()
    }
    
}

extension SaveBoard: NavControllerProgessable {
    
    func navcontrollerProgressionType(_ nav: NavController) -> ProgressionType {
        return .finished
    }
    
    func navcontroller(_ nav: NavController, hitProgressWithType progressionType: ProgressionType) {
        if progressionType == .finished {
            updateProjectName()
        }
    }
    
}

extension SaveBoard: BoardInstantiable {
    
    static var storyboard: String { return "Board" }
    static var nib: String { return "SaveBoard" }
}

//extension SaveBoard: NSTextFieldDelegate {
//    
//    override func controlTextDidChange(_ obj: Notification) {
//        updateProgression()
//    }
//    
//}
