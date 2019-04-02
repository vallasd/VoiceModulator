//
//  Optional.swift
//  VoiceModulator
//
//  Created by David Vallas on 3/20/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

extension Optional {
    
    var importFile: ImportFile {
        if let dict = self as? HGDICT { return ImportFile.decode(object: dict) }
        HGReport.shared.report("optional: |\(String(describing: self ?? nil))| is not Entity mapable, returning new ImportFile", type: .error)
        return ImportFile.new
    }
    
    var importFiles: [ImportFile] {
        if let array = self as? HGARRAY { return ImportFile.decode(object: array) }
        HGReport.shared.report("optional: |\(String(describing: self))| is not [ImportFile] mapable, returning []", type: .error)
        return []
    }
    
    var store: Store {
        if let dict = self as? HGDICT { return Store.decode(object: dict) }
        HGReport.shared.report("optional: |\(String(describing: self))| is not Store mapable, returning new Store", type: .error)
        return Store.new
    }
    
    var project: Project {
        if let dict = self as? HGDICT { return Project.decode(object: dict) }
        HGReport.shared.report("optional: |\(String(describing: self))| is not Project mapable, returning new Project", type: .error)
        return Project.new
    }
    
}
