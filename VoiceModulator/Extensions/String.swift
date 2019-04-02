//
//  String.swift
//  VoiceModulator
//
//  Created by David Vallas on 4/25/18.
//  Copyright © 2018 Phoenix Labs. All rights reserved.
//

import Foundation

extension Array where Element == String {
    
    var encode: String {
        return self.map { $0 }.joined(separator: " ")
    }
    
    /// Example: [ball1, ball8, ball5 orange34], largestNum(string: "ball") would return 8
    func largestNum(string: String) -> Int {
        let matches = self.filter { $0.range(of:string) != nil }
        let numStrings = matches.map { $0.replacingOccurrences(of: string, with: "") }
        let nums = numStrings.map { Int($0) ?? 0 }
        let sorted = nums.sorted()
        return sorted.count > 0 ? sorted.last! : 0
    }
}


