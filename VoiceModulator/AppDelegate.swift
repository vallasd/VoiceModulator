//
//  AppDelegate.swift
//  MicrophoneAnalysis
//
//  Created by Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa

/// global reference to the app Delegate.
let appDelegate = NSApplication.shared.delegate as! AppDelegate
var project: Project { return appDelegate.store.project }

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    weak var mainWindowController: MainWindowController!
    var store: Store = Store(uniqIdentifier: "defaultStore")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
