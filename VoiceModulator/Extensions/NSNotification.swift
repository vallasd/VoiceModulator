//
//  NSNotification.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/10/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

extension Notification {
    
    /* Field Text Delivered from NSNotifications NSTextFieldDelegate (such as: controlTextDidEndEditing), this will return the string of the field */
    var textFieldString: String? {
        if let info = self.userInfo {
            let key = NSString(string: "NSFieldEditor")
            let field = info[key] as? NSTextView
            let string = field?.string
            return string
        }
        return nil
    }
}
