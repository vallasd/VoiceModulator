//
//  CellType.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/10/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

enum CellType {

    case defaultCell
    case imageCell
    case fieldCell1
    case fieldCell2
    case fieldCell3
    case mixedCell1
    
    /// The nib identifier
    var identifier: String {
        switch (self) {
        case .defaultCell: return "DefaultCell"
        case .imageCell: return "ImageCell"
        case .fieldCell1: return "FieldCell1"
        case .fieldCell2: return "FieldCell2"
        case .fieldCell3: return "FieldCell3"
        case .mixedCell1: return "MixedCell1"
        }
    }
    
    /// number of image buttons per row for given cell type
    func imagesPerRow(rowWidth: CGFloat) -> Int {
        switch self {
        case .defaultCell, .mixedCell1: return 1
        case .imageCell:
            let imageWidth = rowHeight - HGCellImageBorder
            let numImages = Int(rowWidth / imageWidth)
            let sidePadding = 2 * HGCellImageBorder
            let totalSpaceNeeded = (CGFloat(numImages) * imageWidth) + sidePadding
            let images = totalSpaceNeeded <= rowWidth ? numImages : numImages - 1
            return images
        default: return 0
        }
    }
    
    /// returns an suggested row height for HGCell given a Table
    var rowHeight: CGFloat {
        switch (self) {
        case .imageCell, .fieldCell3, .mixedCell1: return 60
        default: return 50
        }
    }
    
    func numRows(rowWidth: CGFloat, items: Int) -> Int {
        if items == 0 { return 0 }
        switch (self) {
        case .imageCell:
            let ipr = imagesPerRow(rowWidth: rowWidth)
            if items % ipr == 0 {
                return items / ipr
            }
            return (items / ipr) + 1
        default: return items
        }
    }
}

