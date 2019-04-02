//
//  NSImage.swift
//  VoiceModulator
//
//  Created by David Vallas on 10/1/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

extension NSImage {
    
    /// Returns an image that has a title displayed in bottom half of icon
    static func image(named name: String, title: String) -> NSImage {
        let imageName = NSImage.Name(name)
        let image = NSImage(named: imageName)!
        let viewFrame = NSRect(x: 0,
                               y: 0,
                               width: image.size.width,
                               height: image.size.height)
        let view = NSImageView(frame: viewFrame)
        let labelWidth = image.size.width * 0.9
        let labelFrame = NSRect(x: (image.size.width - labelWidth) / 2.0,
                                y: 0,
                                width: labelWidth,
                                height: image.size.height * 0.5)
        let label = NSTextField(frame: labelFrame)
        let textSize = title.count < 8 ? labelWidth * 0.2 : labelWidth * 0.15
        let font = NSFont.systemFont(ofSize: textSize)
        label.alignment = .center
        label.font = font
        label.textColor = HGColor.blue.color()
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.stringValue = title
        view.image = image
        view.addSubview(label)
        return view.imageRep
    }
}
