//
//  HGTableCellIdentifier.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/18/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation


// MARK: Private Variables
struct TableCellIdentifier: Hashable {
    var tableId: String?
    var cellId: String
    
    func hash(into hasher: inout Hasher) {
        let t = tableId ?? "NotDefined"
        hasher.combine(t)
        hasher.combine(cellId)
    }
}

extension TableCellIdentifier: Equatable {}
func ==(lhs: TableCellIdentifier, rhs: TableCellIdentifier) -> Bool {
    return lhs.tableId == rhs.tableId && lhs.cellId == rhs.cellId
}
