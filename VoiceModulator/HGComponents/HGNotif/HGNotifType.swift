//
//  HGNotifType.swift
//  VoiceModulator
//
//  Created by David Vallas on 1/4/16.
//  Copyright © 2016 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

enum HGNotifType {
    
    case projectChanged
    case entityUpdated
    case entitySelected
    case enumUpdated
    case enumSelected
    case enumCaseUpdated
    case enumCaseSelected
    case attributeUpdated
    case attributeSelected
    case relationshipUpdated
    case relationshipSelected
    case indexUpdated
    
    /// returns a string that identifies the HGNotifType
    var string: String {
        switch self {
        case .projectChanged: return "ProjectChanged"
        case .entityUpdated: return "EntityUpdated"
        case .entitySelected: return "EntitySelected"
        case .enumUpdated: return "EnumUpdated"
        case .enumSelected: return "EnumSelected"
        case .enumCaseUpdated: return "EnumCaseUpdated"
        case .enumCaseSelected: return "EnumCaseSelected"
        case .attributeUpdated: return "AttributeUpdated"
        case .attributeSelected: return "AttributeSelected"
        case .relationshipUpdated: return "RelationshipUpdated"
        case .relationshipSelected: return "RelationshipSelected"
        case .indexUpdated: return "IndexUpdate"
        }
    }
}

extension HGNotifType {
    
    /// returns a unique string that identifies an HGNotifType for a particular uniq ID
    func uniqString(forUniqId uniqID: String) -> String {
        let string = self.string
        return string + "_" + uniqID
    }
    
    /// returns a list of uniq strings that identifies an HGNotifTypes for a particular uniq ID
    static func uniqStrings(forNotifTypes notifTypes: [HGNotifType], uniqID: String) -> [String] {
        var strings: [String] = []
        for notif in notifTypes {
            let string = notif.uniqString(forUniqId: uniqID)
            strings.append(string)
        }
        return strings
    }
}
