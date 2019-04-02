//
//  HGColor.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/16/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

enum HGColor {
    
    case grey
    case white
    case whiteTranslucent
    case clear
    case black
    case purple
    case cyan
    case blue
    case blueBright
    case red
    case green
    case orange
    
    
    func cgColor() -> CGColor {
        switch (self) {
        case .grey: return CGColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        case .white: return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .whiteTranslucent: return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
        case .clear: return CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        case .black: return CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .purple: return CGColor(red: 0.36, green: 0.15, blue: 0.60, alpha: 1.0)
        case .cyan: return CGColor(red: 0.67, green: 0.05, blue: 0.57, alpha: 1.0)
        case .blue: return CGColor(red: 0.11, green: 0.00, blue: 0.81, alpha: 1.0)
        case .blueBright: return CGColor(red: 0.05, green: 0.05, blue: 1.00, alpha: 0.6)
        case .red: return CGColor(red: 0.77, green: 0.10, blue: 0.09, alpha: 1.0)
        case .green: return CGColor(red: 0.00, green: 0.45, blue: 0.00, alpha: 1.0)
        case .orange: return CGColor(red: 0.70, green: 0.40, blue: 0.20, alpha: 1.0)
        }
    }
    
    func color() -> NSColor {
        switch (self) {
        case .grey: return NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        case .white: return NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .whiteTranslucent: return NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
        case .clear: return NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        case .black: return NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .purple: return NSColor(calibratedRed: 0.36, green: 0.15, blue: 0.60, alpha: 1.0)
        case .cyan: return NSColor(calibratedRed: 0.67, green: 0.05, blue: 0.57, alpha: 1.0)
        case .blue: return NSColor(calibratedRed: 0.11, green: 0.00, blue: 0.81, alpha: 1.0)
        case .blueBright: return NSColor(calibratedRed: 0.05, green: 0.05, blue: 1.00, alpha: 0.6)
        case .red: return NSColor(calibratedRed: 0.77, green: 0.10, blue: 0.09, alpha: 1.0)
        case .green: return NSColor(calibratedRed: 0.00, green: 0.45, blue: 0.00, alpha: 1.0)
        case .orange: return NSColor(calibratedRed: 0.70, green: 0.40, blue: 0.20, alpha: 1.0)
        }
    }
}


