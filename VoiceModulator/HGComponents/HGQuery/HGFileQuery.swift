//
//  HGFileQuery.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/1/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

class HGFileQuery {
    
    static let shared = HGFileQuery()

    func importFiles(forPath path: String, completion: @escaping (_ importFiles: [ImportFile]) -> Void)  {
        let mdq = NSMetadataQuery()
        addQueryCompleteObserver(mdq: mdq, completion: completion)
        queryXCODEprojects(mdq: mdq, path: path)
    }
    
    fileprivate func queryXCODEprojects(mdq: NSMetadataQuery, path: String) {
        mdq.searchScopes = [path]
        let fileExtension = "*.xcdatamodeld"
        mdq.predicate = NSPredicate(format: "%K like %@", NSMetadataItemFSNameKey, fileExtension)
        mdq.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemContentModificationDateKey, ascending: false)]
        mdq.start()
    }
    
    fileprivate func addQueryCompleteObserver(mdq: NSMetadataQuery, completion: @escaping (_ importFiles: [ImportFile]) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil, queue: queue) { [weak self] (NSMetadataQueryDidFinishGatheringNotification) -> Void in
            var importFiles: [ImportFile] = []
            let lastUpdate = Date()
            for item in mdq.results {
                guard let displayName = (item as AnyObject).value(forAttribute: NSMetadataItemDisplayNameKey) as? String else { break }
                guard let modificationDate = (item as AnyObject).value(forAttribute: NSMetadataItemContentModificationDateKey) as? Date else { break }
                guard let creationDate = (item as AnyObject).value(forAttribute: NSMetadataItemContentCreationDateKey) as? Date else { break }
                guard let pathKey = (item as AnyObject).value(forAttribute: NSMetadataItemPathKey) as? String else { break }
                let name = displayName.stringByDeletingPathExtension
                let path = "\(pathKey)/\(name).xcdatamodel/contents"
                if FileManager.default.fileExists(atPath: path) == false { break }
                let importFile = ImportFile(name: name, lastUpdate: lastUpdate, modificationDate: modificationDate, creationDate: creationDate, path: path, type: .xcode_XML)
                importFiles.append(importFile)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                if self != nil { NotificationCenter.default.removeObserver(self!) }
                mdq.stop()
                completion(importFiles)
            })
        }
    }
    
    
    
    fileprivate func displayShortItem(item: NSMetadataItem) {
        
        guard let DisplayName = item.value(forAttribute: NSMetadataItemDisplayNameKey) else { print("Error Returning kMDItemDisplayName"); return }
        guard let ContentModificationDate = item.value(forAttribute: NSMetadataItemContentModificationDateKey) else { print("Error Returning kMDItemContentModificationDate"); return }
        guard let ContentCreationDate = item.value(forAttribute: NSMetadataItemContentCreationDateKey) else { print("Error Returning kMDItemContentCreationDate"); return }
        
        print(" DisplayName - \(DisplayName) \n ContentModificationDate - \(ContentModificationDate) \n ContentCreationDate - \(ContentCreationDate) \n")
    }
    
    fileprivate func displayItem(item: NSMetadataItem) {
        guard let ContentTypeTree = item.value(forAttribute: "kMDItemContentTypeTree") else { print("Error Returning kMDItemContentTypeTree"); return }
        guard let ContentType = item.value(forAttribute: "kMDItemContentType") else { print("Error Returning kMDItemContentType"); return }
        guard let PhysicalSize = item.value(forAttribute: "kMDItemPhysicalSize") else { print("Error Returning kMDItemPhysicalSize"); return }
        guard let DisplayName = item.value(forAttribute: "kMDItemDisplayName") else { print("Error Returning kMDItemDisplayName"); return }
        guard let Kind = item.value(forAttribute: "kMDItemKind") else { print("Error Returning kMDItemKind"); return }
        guard let DateAdded = item.value(forAttribute: "kMDItemDateAdded") else { print("Error Returning kMDItemDateAdded"); return }
        guard let ContentModificationDate = item.value(forAttribute: "kMDItemContentModificationDate") else { print("Error Returning kMDItemContentModificationDate"); return }
        guard let ContentCreationDate = item.value(forAttribute: "kMDItemContentCreationDate") else { print("Error Returning kMDItemContentCreationDate"); return }
        guard let FSName = item.value(forAttribute: "kMDItemFSName") else { print("Error Returning kMDItemFSName"); return }
        guard let FSOwnerUserID = item.value(forAttribute: "kMDItemFSOwnerUserID") else { print("Error Returning kMDItemFSOwnerUserID"); return }
        guard let FSLabel = item.value(forAttribute: "kMDItemFSLabel") else { print("Error Returning kMDItemFSLabel"); return }
        
        print("ContentTypeTree - \(ContentTypeTree) \n ContentType - \(ContentType) \n PhysicalSize - \(PhysicalSize) \n DisplayName - \(DisplayName) \n Kind - \(Kind) \n DateAdded - \(DateAdded) \n ContentModificationDate - \(ContentModificationDate) \n ContentCreationDate - \(ContentCreationDate) \n FSName - \(FSName) \n FSOwnerUserID - \(FSOwnerUserID) \n FSLabel - \(FSLabel) \n ")
    }
}
