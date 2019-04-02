//
//  NSEvent.swift
//  VoiceModulator
//
//  Created by David Vallas on 12/21/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

extension NSEvent {
    
    func fullDescription() -> String {
        
        return "NSEvent **** \n type \(self.type) \n modifierFlags \(self.modifierFlags) \n timestamp \(self.timestamp) \n window \(String(describing: self.window)) \n windowNumber \(self.windowNumber) \n context \(String(describing: self.context)) \n clickCount \(self.clickCount) \n buttonNumber \(self.buttonNumber) \n eventNumber \(self.eventNumber) \n locationInWindow \(self.locationInWindow) \n deltaZ \(self.deltaZ) \n hasPreciseScrollingDeltas \(self.hasPreciseScrollingDeltas) \n subtype \(self.subtype) \n absoluteZ \(self.absoluteZ) \n type \(self.type) \n type \(self.type)"
    }

}
