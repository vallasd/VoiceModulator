//
//  Project.swift
//  VoiceModulator
//
//  Created by David Vallas on 11/19/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

// MARK: struct Definition

final class Project {
    
    var name: String
    
    
    init(name: String) {
        self.name = name
    }
    
    static var newName = "New Project"
    
    var isNew: Bool { return name == Project.newName ? true : false }
    
    func saveKey(withUniqID uniqId: String) -> String {
        return uniqId + "__*_|||_*__" + name
    }
    
    static func saveKey(withUniqID uniqId: String, name: String) -> String {
        return uniqId + "__*_|||_*__" + name
    }
}

// MARK: Encoding

extension Project: HGCodable {
    
    static var new: Project {
        return Project(name: Project.newName)
    }
    
    static var encodeError: Project {
        return Project(name: Project.newName)
    }
    
    var encode: Any {
        var dict = HGDICT()
        dict["name"] = name
        return dict
    }
    
    static func decode(object: Any) -> Project {
        let dict = HG.decode(hgdict: object, decoder: Project.self)
        let _ = dict["name"].string
        let project = Project(name: Project.newName)
        return project
    }
}
