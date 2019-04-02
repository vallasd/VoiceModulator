//
//  HGString.swift
//  VoiceModulator
//
//  Created by David Vallas on 8/13/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation
import Cocoa

extension String {
    
    static func random(_ length: Int) -> String {
    
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randString = ""
        
        for _ in 0..<length {
            let randNum = Int(arc4random_uniform(allowedCharsCount))
            let newChar = allowedChars[allowedChars.index(allowedChars.startIndex, offsetBy: randNum)]
            randString += String(newChar)
        }
        
        return randString
    }
    
    var stringByDeletingPathExtension: String {
        let nsstring = self as NSString
        return nsstring.deletingPathExtension
    }
    
    var lastPathComponent: String {
        let nsstring = self as NSString
        return nsstring.lastPathComponent
    }
    
    /// removes all characters
    func stripOutCharactersExcept(_ set: CharacterSet) -> String {
        let stripped = self.components(separatedBy: set.inverted).joined()
        return stripped
    }
    
    /// returns an indexed list of iterated objects that match string in a set of string objects.  Example, string is "New Case", iterated objects are ["Hello", "New Case 2", "Bleepy", "new case 3", "New Case"].  Function will return ["New Case", "New Case 2"].  This search is case sensitive.
    func iteratedObjects(_ objects: [String]) -> [String] {
        
        // TODO: Implement Function
        
        return []
    }
    
    
    /// adds a space and number to end of string. If number does not exist, adds 1, if number exists, add next number.
    var iterated: String {
        
        let stringArray = self.split(separator: " ").map(String.init)
        
        // is not already iterated, return with 2
        if stringArray.count <= 1 {
            return self + " 2"
        }
        
        // is already iterated, return new string with 1 added to number
        if var int = Int(stringArray.last!) {
            int += 1
            let indexes = stringArray.count - 2
            var newString = ""
            for index in 0...indexes {
                newString += stringArray[index]
            }
            newString = newString + " \(int)"
        }
        
        // is not already iterated, return with 2
        return self + " 2"
    }
    
    /// returns string with quotes removed inside string
    var removeQuotes: String {
        let string = self.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        return string
    }
    
    /// simple string, removes all characters besides caps, lower case, and spaces
    fileprivate var simple: String {
        let chars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ_1234567890")
        return self.stripOutCharactersExcept(chars)
    }
    
    /// returns a new string if change was made, else returns nil if the string is already TypeRepresentable
    var changeToTypeRep: String? {
        
        // trim
        var typeRep = self.trimmed
        
        // remove crap symbols, capitalize words and remove spaces
        typeRep = typeRep.simple.components(separatedBy: " ").map { $0.capitalFirstLetter }.joined(separator: "")
        
        // if it is blank, make a New typeRep
        if self == "" || self == "_" {
            typeRep = "NewEntity"
        }
        
        // if type is still same as self, return nil
        if typeRep == self {
            return nil
        }
        
        return typeRep
    }
    
    /// returns a new string if change was made, else returns nil if the string is already VarRepresentable
    var changeToVarRep: String? {
        
        // trim
        var varrep = self.trimmed
        
        // remove crap symbols, capitalize words and remove spaces
        varrep = varrep.simple.components(separatedBy: " ").map { $0.capitalFirstLetter }.joined(separator: "").lowerFirstLetter
        
        // if it is blank, make a New typeRep
        if self == "" || self == "_" {
            varrep = "newVariable"
        }
        
        // if type is still same as self, return nil
        if varrep == self {
            return nil
        }
        
        return varrep
    }
    
    /// removes extra white spaces and new lines
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// makes a Type [Entity, Struct,  representation of the string
    var typeRepresentable: String {
        return self.simple.components(separatedBy: " ").map { $0.capitalFirstLetter }.joined(separator: "")
    }
    
    /// makes a variable representation of the string
    var varRepresentable: String {
        return self.typeRepresentable.lowerFirstLetter
    }
    
    /// capitalizes the first letter in the string
    var capitalFirstLetter: String {
        if self.isEmpty { return "" }
        var s = self
        s.replaceSubrange(s.startIndex...s.startIndex, with: String(s[s.startIndex]).capitalized)
        return s
    }
    
    /// lower cases the first letter in the string
    var lowerFirstLetter: String {
        if self.isEmpty { return "" }
        var string = self
        let firstChar = String(string.first!).lowercased()
        string.replaceSubrange(string.startIndex...string.startIndex, with: firstChar)
        return string
    }
    
    /// makes first letter of string lower case and appends "Array" to the end of string
    var lowerFirstLetterAndArray: String {
        if self.isEmpty { return "" }
        let string = self.lowerFirstLetter
        return string + "Array"
    }
    
    /// adds "Set" to end of string
    var setRep: String {
        return self + "Set"
    }
    
    /// wraps Set<> around string
    var pluralRep: String {
        return "Set<\(self)>"
    }
    
    /// add "Nullable" to end of string
    var nilRep: String {
        return self + "Nullable"
    }
    
    
}
