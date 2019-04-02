//
//  DevFolder.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/11/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation



struct Folder {
    let name: String
    let path: String
    let importFiles: [ImportFile]
    
    static func create(name: String, path: String, completion: @escaping (_ newfolder: Folder) -> Void) {
        ImportFile.importFiles(path: path) { (importFiles) -> Void in
            completion(Folder(name: name, path: path, importFiles: importFiles))
        }
    }
}

extension Folder: HGCodable {
    
    static var new: Folder {
        return Folder(name: "New Folder", path: "/", importFiles: [] )
    }
    
    static var encodeError: Folder {
        return Folder(name: "New Folder", path: "/", importFiles: [] )
    }
    
    var encode: Any {
        var dict = HGDICT()
        dict["name"] = name
        dict["path"] = path
        dict["importFiles"] = importFiles.encode
        return dict as AnyObject
    }
    
    static func decode(object: Any) -> Folder {
        let dict = HG.decode(hgdict: object, decoder: Folder.self)
        let name = dict["name"].string
        let path = dict["path"].string
        let importFiles = dict["importFiles"].importFiles
        return Folder(name: name, path: path, importFiles: importFiles)
    }
}
