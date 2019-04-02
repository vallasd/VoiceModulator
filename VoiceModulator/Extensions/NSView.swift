//
//  NSView.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/17/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

extension NSView {
    
    /// adds a corner to the view
    func roundedCorner() {
        layer?.masksToBounds = true
        layer?.cornerRadius = 20.0
    }
    
    /// adds a shadow to the view's sides
    func dropshadow() {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black
        shadow.shadowOffset = NSMakeSize(0, -10.0)
        shadow.shadowBlurRadius = 10.0
        self.wantsLayer = true
        self.shadow = shadow
    }
    
    /// creates a background panel for the view
    func addPanel(insets i: CGFloat) {
        let frame = getFrame(self.bounds, inset: i)
        let panel = NSView(frame: frame)
        panel.backgroundColor(HGColor.white)
        panel.roundedCorner()
        panel.dropshadow()
        panel.insert(inParent: self, below: nil, inset: i)
    }
    
    /// inserts a view below the subview provided.  If no subview is provided, will insert the view at the bottom of the parent views hierarchy.  The view will resize according to the parent views size.
    func insert(inParent p: NSView, below: NSView?, inset i: CGFloat) {
        frame = getFrame(p.bounds, inset: i)
        translatesAutoresizingMaskIntoConstraints = true
        p.addSubview(self, positioned: .below, relativeTo: below)
        frame.origin = origin(p, view: self)
        autoresizingMask = [.width, .height]
    }
    
    /// adds a view to be in the center of its parent, view will not resize with the parent
    func center(inParent p: NSView) {
        frame.origin = origin(p, view: self)
        autoresizingMask =  [.minXMargin,
                             .maxXMargin,
                             .minYMargin,
                             .maxYMargin]
        p.addSubview(self)
    }
    
    /// adds view to be the same size as its parent, view will resize with the parent
    func resize(inParent p: NSView) {
        frame = CGRect(x: 0, y: 0, width: p.frame.width, height: p.frame.height)
        translatesAutoresizingMaskIntoConstraints = true
        p.addSubview(self)
        frame.origin = origin(p, view: self)
        autoresizingMask = [.width, .height]
    }
    
    fileprivate func getFrame(_ bounds: CGRect, inset i: CGFloat) -> NSRect {
        let i2 = 2.0 * i
        return NSRect(x: i,
                      y: i,
                      width: bounds.size.width - i2,
                      height: bounds.size.height - i2)
    }
    
    fileprivate func origin(_ p: NSView, view: NSView) -> NSPoint {
        return NSMakePoint((p.bounds.width / 2.0) - (view.frame.width / 2.0),
                           (p.bounds.height / 2.0) - (view.frame.height / 2.0))
    }
    
    /// turns interaction on or off for all subviews in the view
    fileprivate func interaction(_ enabled: Bool) {
        for view in self.subviews {
            if let control = view as? NSControl { control.isEnabled = enabled }
            else { view.interaction(enabled) }
        }
    }
    
    /// removes constraints in view and subviews
    func removeAllConstraints() {
        
        print("A: constraints for view: \(constraints.count) subviews: \(subviews.map { $0.constraints.count })")
        
        for constraint in self.constraints {
            self.removeConstraint(constraint)
        }
        
        for subview in self.subviews {
            for constraint in subview.constraints {
                subview.removeConstraint(constraint)
            }
        }
        
        print("B: constraints for view: \(constraints.count) subviews: \(subviews.map { $0.constraints.count })")
    }
    
    /// returns an NSView that can be used as a spacer
    static var spacer: NSView {
        let spacer = NSView()
        spacer.makeConstrainable()
        return spacer
    }
    
    /// remove all auto resizing and masks for
    func makeConstrainable() {
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.height, .width, .maxXMargin, .maxYMargin, .minXMargin, .minYMargin]
        for subview in self.subviews {
            subview.makeConstrainable()
        }
    }
    
    /// sets background to an HGColor
    func backgroundColor(_ color: HGColor) {
        let layer = CALayer()
        layer.backgroundColor = color.cgColor()
        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        self.wantsLayer = true
        self.layer = layer
    }
    
    /// converts a NSView to an NSImage
    var imageRep: NSImage {
        let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds)!
        self.cacheDisplay(in: self.bounds, to: rep)
        let img = NSImage(size: self.bounds.size)
        img.addRepresentation(rep)
        return img
    }
    
    
}
