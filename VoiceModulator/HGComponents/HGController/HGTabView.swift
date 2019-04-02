//
//  HGTabVC.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/29/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

/// This class is not implemented yet
class HGTabView: NSTabView {
    
    override func keyDown(with theEvent: NSEvent) {
        let command = theEvent.command()
        switch command {
        case .tabLeft: selectPreviousTabViewItem(self)
        case .tabRight: selectNextTabViewItem(self)
        default: break // Do Nothing
        }
    }
}
