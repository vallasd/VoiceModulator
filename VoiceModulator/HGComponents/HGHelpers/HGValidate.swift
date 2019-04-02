//
//  HGValidate.swift
//  VoiceModulator
//
//  Created by David Vallas on 4/26/18.
//  Copyright © 2018 Phoenix Labs. All rights reserved.
//

import Foundation

struct HGValidate {
    
    static func validate<T,U>(value: Any, key: Any, decoder: U) -> T? {
        if let v = value as? T { return v }
        HGReport.shared.validateFailed(decoder: U.self, value: value, key: key, expectedType: T.self)
        return nil
    }
    
    static func validateFloat<T>(value: Any, key: Any, decoder: T) -> Float? {
        if let d = value as? Double { return Float(d) }
        if let i = value as? Int { return Float(i) }
        if let f = value as? Float { return f }
        HGReport.shared.validateFailed(decoder: T.self, value: value, key: key, expectedType: T.self)
        return nil
    }
    
    static func validateInt8<T>(value: Any, key: Any, decoder: T) -> Int8? {
        if let i = value as? Int { return Int8(i) }
        if let d = value as? Double { return Int8(d) }
        if let i8 = value as? Int8 { return i8 }
        if let f = value as? Float { return Int8(f) }
        HGReport.shared.validateFailed(decoder: T.self, value: value, key: key, expectedType: T.self)
        return nil
    }
    
}
