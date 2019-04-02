//
//  NSLayoutConstraint.swift
//  VoiceModulator
//
//  Created by David Vallas on 4/22/18.
//  Copyright © 2018 Phoenix Labs. All rights reserved.
//

import Cocoa

extension NSLayoutConstraint {
    
    static func aspectRatio(view: Any, ratio: CGFloat) -> NSLayoutConstraint {
        let w = NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .height,
                                   multiplier: ratio,
                                   constant: 0.0)
        w.priority = .defaultHigh
        return w
    }
    
    static func width(view: Any, toView: Any, multipler: CGFloat) -> NSLayoutConstraint {
        let w = NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: toView,
                                   attribute: .width,
                                   multiplier: multipler,
                                   constant: 0.0)
        w.priority = .defaultLow
        return w
    }
    
    static func size(view: Any, toView: Any, multipler: CGFloat) -> [NSLayoutConstraint] {
        let w = width(view: view, toView: toView, multipler: multipler)
        let h = NSLayoutConstraint(item: view,
                                   attribute: .height,
                                   relatedBy: .equal,
                                   toItem: toView,
                                   attribute: .height,
                                   multiplier: multipler,
                                   constant: 0.0)
        
        h.priority = .required
        return [w, h]
    }
    
    static func centerVertically(view: Any, toView: Any) -> NSLayoutConstraint {
        let cv = NSLayoutConstraint(item: view,
                                    attribute: .centerY,
                                    relatedBy: .equal,
                                    toItem: toView,
                                    attribute: .centerY,
                                    multiplier: 1.0,
                                    constant: 0.0)
        cv.priority = .required
        return cv
    }
    
    static func horizontal(left: Any, right: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: left,
                                   attribute: .right,
                                   relatedBy: .equal,
                                   toItem: right,
                                   attribute: .left,
                                   multiplier: 1.0,
                                   constant: -spacing)
        c.priority = .required
        return c
    }
    
    static func verticalSpacing(top: Any, bottom: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: top,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottom,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: -spacing)
        c.priority = .required
        return c
    }
    
    static func top(view: Any, superView: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: view,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: superView,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: spacing)
        c.priority = .required
        return c
    }
    
    static func bottom(view: Any, superView: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: view,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: superView,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: -spacing)
        c.priority = .required
        return c
    }
    
    static func trailing(view: Any, superView: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: view,
                                   attribute: .trailing,
                                   relatedBy: .equal,
                                   toItem: superView,
                                   attribute: .trailing,
                                   multiplier: 1.0,
                                   constant: -spacing)
        c.priority = .required
        return c
    }
    
    static func leading(view: Any, superView: Any, spacing: CGFloat) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: view,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: superView,
                                   attribute: .leading,
                                   multiplier: 1.0,
                                   constant: spacing)
        c.priority = .required
        return c
    }
}
