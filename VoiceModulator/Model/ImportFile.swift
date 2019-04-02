//
//  ModelEntity.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/11/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation
import CoreData

enum ImportFileType: Int16 {
    case xcode_XML = 0
    
    var int: Int {
        return Int(self.rawValue)
    }
    
    static func create(int: Int) -> ImportFileType {
        switch int {
        case 0: return .xcode_XML
        default:
            HGReport.shared.report("int: |\(int)| is not an ImportFileType mapable, using .XCODE_XML", type: .error)
            return .xcode_XML
        }
    }
}

struct ImportFile: Hashable {
    
    let name: String
    let lastUpdate: Date
    let modificationDate: Date
    let creationDate: Date
    let path: String
    let type: ImportFileType
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    static func importFiles(path: String, completion: @escaping (_ importFiles: [ImportFile]) -> Void) {
        HGFileQuery.shared.importFiles(forPath: path) { (importFiles) -> Void in completion(importFiles) }
    }
    
    func save(_ key: String) {
        UserDefaults.standard.setValue(self.encode, forKey: key)
    }
    
    static func open(_ key: String) -> ImportFile? {
        let defaults = UserDefaults.standard
        if let dict = defaults.object(forKey: key) as? HGDICT {
            return ImportFile.decode(object: dict as AnyObject)
        }
        return nil
    }
}

extension ImportFile: Equatable {}; func ==(lhs: ImportFile, rhs: ImportFile) -> Bool { return lhs.path == rhs.path }


extension ImportFile: HGCodable {
    
    static var new: ImportFile {
        let date = Date()
        return ImportFile(name: "", lastUpdate: date, modificationDate: date, creationDate: date, path: "", type: .xcode_XML)
    }
    
    static var encodeError: ImportFile {
        let date = Date()
        return ImportFile(name: "", lastUpdate: date, modificationDate: date, creationDate: date, path: "", type: .xcode_XML)
    }
    
    var encode: Any {
        var dict = HGDICT()
        dict["name"] = name
        dict["lastUpdate"] = lastUpdate.timeIntervalSince1970
        dict["modificationDate"] = modificationDate.timeIntervalSince1970
        dict["creationDate"] = creationDate.timeIntervalSince1970
        dict["path"] = path
        dict["type"] = type.int
        return dict as AnyObject
    }
    
    static func decode(object: Any) -> ImportFile {
        let dict = HG.decode(hgdict: object, decoder: ImportFile.self)
        let name = dict["name"] as! String
        let lastUpdate = dict["lastUpdate"].interval.date()
        let modificationDate = dict["modificationDate"].interval.date()
        let creationDate = dict["creationDate"].interval.date()
        let path = dict["path"].string
        let type = dict["type"].importFileType
        return ImportFile(name: name, lastUpdate: lastUpdate, modificationDate: modificationDate, creationDate: creationDate, path: path, type: type)
    }
}
