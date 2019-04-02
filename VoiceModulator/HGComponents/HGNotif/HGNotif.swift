//
//  HGNotif.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/10/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

/// This class posts and observes Notifications through the NSNotificationCenter.  This class is thread safe.
class HGNotif {
    
    /// removes object from observing Notifications
    static func removeObserver(_ object: AnyObject) {
        NotificationCenter.default.removeObserver(object)
    }
    
    /// adds an observer for a specific notificationName and will perform the block once notification is heard.
    static func addObserverForName(_ name: String, usingBlock block: @escaping (Notification) -> Void) {
        asyncObserveOnMainThreadForName(name, usingBlock: block)
    }
    
    /// posts a single notification with an object
    static func postNotification(_ name: String, withObject object: Any?) {
        asyncPostOnMainThreadWithName([name], object: object)
    }
    
    /// posts a single notification without an object
    static func postNotification(_ name: String) {
        asyncPostOnMainThreadWithName([name], object: nil)
    }
    
    /// posts a multiple notifications without objects
    static func postNotifications(_ names: [String]) {
        asyncPostOnMainThreadWithName(names, object: nil)
    }
    
    fileprivate static func asyncPostOnMainThreadWithName(_ names: [String], object: Any?) {
        DispatchQueue.main.async { () -> Void in
            for name in names {
                NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
            }
        }
    }
    
    fileprivate static func asyncObserveOnMainThreadForName(_ name: String, usingBlock block: @escaping (Notification) -> Void) {
        DispatchQueue.main.async { () -> Void in
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil, using: block)
        }
    }
    
}
