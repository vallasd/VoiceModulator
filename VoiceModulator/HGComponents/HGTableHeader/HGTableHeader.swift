//
//  HGTableHeader.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/3/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

protocol HGTableHeaderDelegate: AnyObject {
    func hgtableheaderDidAdd(_ header: HGTableHeader)
}

class HGTableHeader: NSTableHeaderView {
    
    weak var delegate: HGTableHeaderDelegate?
    
    @IBAction func pressedAdd(_ sender: AnyObject) {
        delegate?.hgtableheaderDidAdd(self)
    }
    
}
