//
//  HGEvent.swift
//  VoiceModulator
//
//  Created by David Vallas on 8/19/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

let HGUpArrowCharacter = 63232
let HGDownArrowCharacter = 63233
let HGLeftArrowCharacter = 63234
let HGRightArrowCharacter = 63235
let HGACharacter = 97
let HGDCharacter = 100
let HGPCharacter = 112

/// List of Available Commands For Huckleberry Gen App generated through Keyboard Interaction.
enum HGCocoaCommand {
    case none
    case addRow
    case deleteRow
    case nextRow
    case previousRow
    case tabLeft
    case tabRight
    case printRowInformation // for debugging only
}

// List of Available Command Options For Huckleberry Gen App generated through Keyboard Interaction.
public struct HGCommandOptions : OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init() {
        self.rawValue = 0
    }
    
    static let MultiSelectOn = HGCommandOptions(rawValue: 1)
    // static let NextOption = HGCommandOptions(rawValue: 2)
    // static let NextOption = HGCommandOptions(rawValue: 4)
    // static let NextOption = HGCommandOptions(rawValue: 8)

}

extension NSEvent {
    
    /// Returns HGCommandOptions for an NSEvent by checking modifier flags to see which option keys (such as Command, Shift, etc) are pressed, returns appropriate Huckleberry Gen option commands to implement.  Use when checking a flagChanged Event.
    func commandOptions() -> HGCommandOptions {
        
        if self.modifierFlags.contains(NSEvent.ModifierFlags.command) {
            return .MultiSelectOn
        }
        
        return HGCommandOptions() // None
    }
    
    /// Returns HGCommand for an NSEvent by checking which key was pressed (such as "a", Delete, Tab) are pressed, returns appropriate Huckleberry Gen command to implement.  Use when checking a KeyDown Event.
    func command() -> HGCocoaCommand {
        
        if let scalars = self.charactersIgnoringModifiers?.unicodeScalars {
            let int = Int(scalars[scalars.startIndex].value)
            // Swift.print(int) // Check Value of Key
            switch int {
            case HGUpArrowCharacter: return .previousRow
            case HGDownArrowCharacter: return .nextRow
            case HGDCharacter, NSDeleteCharacter: return .deleteRow
            case HGACharacter: return .addRow
            case HGLeftArrowCharacter: return .tabLeft
            case HGRightArrowCharacter: return .tabRight
            case HGPCharacter: return .printRowInformation
            default: return .none
            }
        }
        
        return .none
    }
}
