//
//  HGBlockView.swift
//  VoiceModulator
//
//  Created by David Vallas on 12/21/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

/// NSView that will block the background views from any mouseclicks or touches (mousedown)
class HGBlockView: NSView {
    
    override func mouseDown(with theEvent: NSEvent) {
        // do nothing
    }
    
}
