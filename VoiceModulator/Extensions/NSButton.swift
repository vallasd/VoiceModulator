//
//  NSButton.swift
//  VoiceModulator
//
//  Created by David Vallas on 4/21/18.
//  Copyright © 2018 Phoenix Labs. All rights reserved.
//

import Cocoa

extension NSButton {
    
    static var imageButton: NSButton {
        let button = NSButton()
        button.bezelStyle = .regularSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false
        button.isTransparent = false
        button.state = .off
        button.allowsMixedState = false
        button.isSpringLoaded = false
        button.alignment = .center
        if #available(OSX 10.12, *) {
            button.imageHugsTitle = false
        }
        button.imagePosition = .imageOnly
        button.isEnabled = true
        button.imageScaling = .scaleProportionallyUpOrDown
        button.makeConstrainable()
        return button
    }
    
    
}
