//
//  NSScreen.swift
//  VoiceModulator
//
//  Created by David Vallas on 2/21/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

extension NSScreen {
    
    /// returns an array of screen sizes for the current mac with main screen size at index 0
    static func screenRects() -> [CGRect] {
        
        // create mainScreen rect and get all screens
        var rects: [CGRect] = []
        let screenArray = self.screens
        let mainScreenFrame = self.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        
        // convert screens to rects and store in sizes array
        for screen in screenArray {
            let rect = screen.visibleFrame
            if rect == mainScreenFrame { rects.insert(rect, at: 0) }
            else { rects.append(rect) }
        }
        
        // returns rects
        return rects
    }
}
