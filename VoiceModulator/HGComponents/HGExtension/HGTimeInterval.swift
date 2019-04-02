//
//  HGTimeInterval.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/17/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

extension TimeInterval {
    
    func date() -> Date { return Date(timeIntervalSince1970: self) }
    
}
