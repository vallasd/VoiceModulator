//
//  HuckleberryPiStore.swift
//  HuckleberryPi
//
//  Created by David Vallas on 6/24/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation
import CoreData

final class Store {
    
    /// unique identifier for this Huckleberry Gen store
    fileprivate(set) var uniqIdentifier: String
    
    /// the current path for the XCODE files to import
    var importPath: String
    
    /// the current path for the exporting a Project
    var exportPath: String
    
    /// the project that is currently opened
    var project: Project {
        didSet {
            appDelegate.mainWindowController.window?.title = project.name
            postProjectChanged()
        }
    }
    
    /// a list of saved projects for this store
    fileprivate(set) var savedProjects: [String]
    
    /// Checks defaults to see if a Huckleberry Gen was saved with same identifier and opens that data if available, else returns a blank project with identifier
    init(uniqIdentifier uniqID: String) {
        let file = Store.openDefaults(uniqID) ?? Store.new
        uniqIdentifier = uniqID
        importPath = file.importPath
        exportPath = file.exportPath
        project = file.project
        savedProjects = file.savedProjects
    }
    
    /// initializes Huckleberry Gen when user gives all data
    init(uniqIdentifier: String, importPath: String, exportPath: String, project: Project, savedProjects: [String]) {
        self.uniqIdentifier = uniqIdentifier
        self.importPath = importPath
        self.exportPath = exportPath
        self.project = project
        self.savedProjects = savedProjects
    }
    
    /// clears NSUserDefaults completely
    static func clear() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }
    
    
    /// clears all variables to default values
    func clear() {
        let keys = Array(UserDefaults.standard.dictionaryRepresentation().keys)
        let storeKeys = keys.filter { $0.contains(self.uniqIdentifier) }
        let defaults = UserDefaults.standard
        
        print("Deleting storeKeys: \n\(storeKeys)")
        
        for key in storeKeys {
            defaults.removeObject(forKey: key)
        }
        
        importPath = ""
        exportPath = ""
        project = Project.new
    }
    
    /// saves Store file to user defaults
    func save() {
        self.saveDefaults(uniqIdentifier)
    }
    
    // MARK: Project Manipulation
    
    /// saves or overwrites a project to user defaults
    func saveProject(_ project: Project) {
        
        // if project was not already named, name it and append it to savedProjects
        if project.isNew {
            project.name = "New Project \(Date().mmddyymmss)"
            appDelegate.mainWindowController.window?.title = project.name
            savedProjects.append(project.name)
        }
        
        // create save key, this will always return a string because we know for sure that project has a name
        let key = project.saveKey(withUniqID: uniqIdentifier)
        
        // save defaults
        project.saveDefaults(key)
    }
    
    /// saves the current project to user defaults and creates a key
    func saveCurrentProject() {
        
        // if project was not already named, name it and append it to savedProjects
        if project.isNew {
            project.name = "New Project \(Date().mmddyymmss)"
            appDelegate.mainWindowController.window?.title = project.name
            savedProjects.append(project.name)
        }
        
        // create save key, this will always return a string because we know for sure that project has a name
        let key = project.saveKey(withUniqID: uniqIdentifier)
        
        // save defaults
        project.saveDefaults(key)
    }
    
    /// deletes a project at index of savedProjects, return true if project was successfully deleted
    func deleteProject(atIndex index: Int) -> Bool {
    
        // index out of bounds
        if savedProjects.indices.contains(index) == false {
            HGReport.shared.report("savedProjects attempting to delete index that is out of bound", type: .error)
            return false
        }
        
        // create save key, this will always return a string because we know for sure that project has a name
        let key = Project.saveKey(withUniqID: uniqIdentifier, name: savedProjects[index])
        
        // remove project from defaults
        Project.removeDefaults(key)
        
        // remove project from index
        savedProjects.remove(at: index)
        
        return true
    }
    
    /// open a project at index of savedProjects, return true if project was successfully opened
    func openProject(atIndex index: Int) -> Bool {
        
        // index out of bounds
        if savedProjects.indices.contains(index) == false {
            HGReport.shared.report("savedProjects attempting to open index that is out of bound", type: .error)
            return false
        }
        
        // create save key, this will always return a string because we know for sure that project has a name
        let key = Project.saveKey(withUniqID: uniqIdentifier, name: savedProjects[index])
        
        // opens project from defaults
        project =? Project.openDefaults(key)
        
        return true
    }
    
    /// changes name of project at index of savedProjects to supplied, return true if project name was successfully changed
    func changeCurrentProject(toName name: String) -> Bool {
        
        // set original name
        let originalName = project.name
        
        // remove original name
        if savedProjects.contains(originalName) {
            // remove original name and name from savedProjects if they exist
            savedProjects = savedProjects.filter { $0 != originalName && $0 != name }
        }
        
        // change name
        project.name = name
        
        // add new name to top of index
        savedProjects.insert(name, at: 0)
        
        // update title bar
        appDelegate.mainWindowController.window?.title = project.name
    
        // create save keys
        let oldKey = Project.saveKey(withUniqID: uniqIdentifier, name: originalName)
        let key = project.saveKey(withUniqID: uniqIdentifier)
        
        // delete old key
        Project.removeDefaults(oldKey)
        
        // save new key
        project.saveDefaults(key)
        
        return true
    }
    
    /// exports a project to a series of files and directories
    func exportProject() {
        HGReport.shared.report("exporting project fails", type: .error)
//        print("Exporting the Project to \(exportPath)")
//        let ep = ExportProject(store: self)
//        ep.export()
    }
    
    
    // MARK: Notifications
    
    /// returns a store unique Notification Name for a particular HGNotifType
    func notificationNames(forNotifTypes notifs: [HGNotifType]) -> [String] {
        var names: [String] = []
        for notif in notifs {
            names.append(notif.uniqString(forUniqId: uniqIdentifier))
        }
        return names
    }
    
    /// returns a store unique Notification Name for a particular HGNotifType
    func notificationName(forNotifType notif: HGNotifType) -> String {
        return notif.uniqString(forUniqId: uniqIdentifier)
    }
    
    /// posts a notification that is unique to store
    func post(forNotifType notif: HGNotifType) {
        let uniqNotif = notificationName(forNotifType: notif)
        HGNotif.postNotification(uniqNotif)
    }
    
    /// posts a mass notification to every sub component when the project has changed
    fileprivate func postProjectChanged() {
        let notifType = HGNotifType.projectChanged
        let post = notifType.uniqString(forUniqId: uniqIdentifier)
        HGNotif.postNotification(post)
    }
}

extension Store: HGCodable {
    
    static var new: Store {
        let uuid = UUID().uuidString
        return Store(uniqIdentifier: uuid, importPath: "/", exportPath: "/", project: Project.new, savedProjects: [])
    }
    
    static var encodeError: Store {
        let uuid = UUID().uuidString
        return Store(uniqIdentifier: uuid, importPath: "/", exportPath: "/", project: Project.new, savedProjects: [])
    }
    
    var encode: Any {
        var dict = HGDICT()
        dict["uniqIdentifier"] = uniqIdentifier
        dict["importPath"] = importPath
        dict["exportPath"] = exportPath
        dict["project"] = project.encode
        dict["savedProjects"] = savedProjects
        return dict as AnyObject
    }
    
    static func decode(object: Any) -> Store {
        let dict = HG.decode(hgdict: object, decoder: Store.self)
        let uniqIdentifier = dict["uniqIdentifier"].string
        let importPath = dict["importPath"].string
        let exportPath = dict["exportPath"].string
        let project = dict["project"].project
        let savedProjects = dict["savedProjects"].stringArray
        return Store(uniqIdentifier: uniqIdentifier, importPath: importPath, exportPath: exportPath, project: project, savedProjects: savedProjects)
    }
}
