//
//  FIRManager.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase



class FIRManager: NSObject {
    
    // Singleton
    static let sharedInstance = FIRManager()
    
    // Properties
    var database: FIRDatabaseReference {
        get{ return FIRDatabase.database().reference()
        }
    }
    var storageBucketURLString: String {
        get {
             return FIRApp.defaultApp()!.options.storageBucket
        }
    }
    // Reference to storage bucket
    var storage: FIRStorageReference {
        get {
            return FIRStorage.storage().reference(forURL: "gs://" + storageBucketURLString)
        }
    }
    var uniqueIdentifier: String {
        get {
            return "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
        }
    }

    private override init() {
        super.init()
    }

// Methods
    
    func observeDatabaseObject(named: String, event: FIRDataEventType, completion:@escaping (FIRDataSnapshot)->()) -> FIRDatabaseHandle {
        // Listen for new messages in the Firebase database
        return database.child(named).observe(event, with: completion)
        //typical completion handler code:
        /*
         self.model.append(snapshot)
         self.tableView.insertRows(at: [IndexPath(row: self.videos.count-1, section: 0)], with: .automatic)
         */
    }
    
    func removeObserverDatabaseObject(named: String, handle: FIRDatabaseHandle) {
        database.child(named).removeObserver(withHandle: handle)
    }

    func putObjectOnStorage(data: Data, contentType: FIRManager.ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        storage.addObject(data: data, contentType: contentType, completion: completion)
    }
    
    func putObjectOnDatabase(named: String, data: [String: AnyObject?], completion:@escaping (FIRDatabaseReference, Error?)->()) {
        database.addObject(named: named, data: data, completion: completion)
    }
    
    func putVideo(url: URL) {
        
    }
    
    func putVideoComposition(composition: VideoComposition) {
        
    }
    
// Reference data structure
    enum ContentType {
        case image, movie, audio
        func string() -> String {
            switch self {
            case .image:
                return "image/jpeg"
            case .movie:
                return "movie/mov"
            case .audio:
                return "audio/mp3"
            }
        }
        func fileExtension() -> String {
            switch self {
            case .image:
                return "jpeg"
            case .movie:
                return "mov"
            case .audio:
                return "mp3"
            }
        }
    }
    
    enum ObjectKey {
        static let video = "video"
        static let template = "template"
    }
    
}

// MARK:- Extensions

extension FIRDatabaseReference {
    // Push new "object" to FIR Database
    // Object data is dictionary of String: AnyObject? format
    // Resulting reference (& .key) is handed to completion block as FIRDatabaseReference
    
    // TODO: - bug submitted to Google for extension causing undue Sef 11 fault

    func addObject(named: String, data: [String: AnyObject?], completion:@escaping (FIRDatabaseReference, Error?)->()) {
        // Put to Database
        child(named).childByAutoId().setValue(data){ (error, ref) in
            if let error = error {
                print("Error adding object to FIR Database: \(error.localizedDescription)")
                return
            }
            completion(ref, error)
        }
    }
 
}
 

extension FIRStorageReference {
    func addObject(data: Data, contentType:FIRManager.ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        let path = FIRManager.sharedInstance.uniqueIdentifier + contentType.fileExtension()
        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType.string()

        // Put to Storage
        child(path).put(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
                return
            }
            completion(metadata, error)
        }

    }
}

extension FIRDataSnapshot {
    var dictionary: [String: AnyObject?] {
        get {
            return self.value as! [String: AnyObject?]
        }
    }
}

extension String {
    var isCloudStorage: Bool {
        get {
            return self.hasPrefix("gs://")
        }
    }
}
