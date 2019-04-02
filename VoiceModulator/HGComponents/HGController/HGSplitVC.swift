//
//  HGSplitVC.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/6/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

class HGSplitVC: NSViewController {
    
    let hgsplit = HGSplit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlSplits(inView: view)
        hgsplit.openall(false)
    }
    
    fileprivate func controlSplits(inView view: NSView) {
        for subview in view.subviews {
            if let splitview = subview as? NSSplitView {
                let dividers = splitview.numDividers()
                if dividers == 1 {
                    if splitview.isVertical  { hgsplit.add(splitview, proportion: .half, reverse: false) }
                    else { hgsplit.add(splitview, proportion: .half, reverse: true) }
                } else {
                    hgsplit.add(splitview, proportion: .fifth, reverse: false)
                }
            }
        } 
    }
}

