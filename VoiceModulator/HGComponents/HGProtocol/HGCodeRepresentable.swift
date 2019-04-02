//
//  HGCodeRepresentable.swift
//  VoiceModulator
//
//  Created by David Vallas on 1/28/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

// This objects used for Exporting Code.  They should be string representations of XCODE key terms.  Stuff that will turn Blue.

extension Array where Element == String {
    
    func iteratedTypeRepresentable(string: String) -> String {
        let name = string.typeRepresentable
        if self.contains(name) {
            let largestNum = self.largestNum(string: name)
            return name + "\(largestNum + 1)"
        }
        return name
    }
    
    func iteratedVarRepresentable(string: String) -> String {
        let name = string.varRepresentable
        if self.contains(name) {
            let largestNum = self.largestNum(string: name)
            return name + "\(largestNum + 1)"
        }
        return name
    }
}
