//
//  NSRect.swift
//  VoiceModulator
//
//  Created by David Vallas on 4/22/18.
//  Copyright © 2018 Phoenix Labs. All rights reserved.
//

import Foundation

extension NSRect {
    
    var info: String {
        let b = self
        return "origin: \(b.origin.x.rounded()),\(b.origin.y.rounded()) size: \(b.width.rounded()),\(b.height.rounded())"
    }
    
}
