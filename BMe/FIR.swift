//
//  FIR.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/4/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseCore
import FirebaseAuth

/**
 Firebase Storage and Database wrapper class
 */
class FIR: NSObject {
    /** Singleton accessor */
    static let manager = FIR()
    private override init() {
        super.init()
        
        // Set logging to true
//        FIRDatabase.setLoggingEnabled(true)
    }
    
    /** Storage URL prefix ("gs://") */
    static var storagePrefix = "gs://"
    /** FIRDatabase reference */
    let database = FIRDatabase.database().reference()
    /** FIRStorage reference */
    let storage = FIRStorage.storage().reference(forURL: storagePrefix + FIRApp.defaultApp()!.options.storageBucket)
    /** User ID */
    private(set) var uid = FIRAuth.auth()!.currentUser!.uid

    /** Returns the database reference for a given object */
    func databasePath(_ object:object) -> FIRDatabaseReference {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return database.child(object.key())
    }
    
    /** Returns the storage reference for a given object */
    func storagePath(_ object: object) -> FIRStorageReference {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return storage.child(object.key())
    }
    
    /** 
     Save to storage and insert object JSON to Database
     Returns the filename to completion handler
     */
    func put(file data: Data, object: object, completion: @escaping (String)->()) {
        // Put file on storage
        // Get unique path using UID as root
        let path = storagePath(object)
        let filename = database.childByAutoId().key
        let fileExtension = object.fileExtension()

        // Construct meta data for file upload
        let metadata = FIRStorageMetadata()
        metadata.contentType = object.contentType()
        metadata.customMetadata = ["uid": uid]
        
        // Put to Storage
        let task = path.child(filename + fileExtension).put(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
            }
            else {
                // Write object info to database
                let json = ["uid": self.uid,
                            "object": object.key(),
                            "timestamp": Date().toString(),
                            "storageURL": metadata?.storageURL]
                self.databasePath(object).child(filename).setValue(json)
                
                // Send to handler
                completion(filename)
            }
        }
        
        task.observe(.progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload \(percentComplete)% completed loading")
        })
        
        task.observe(.success, handler: { (snapshot: FIRStorageTaskSnapshot) in
            print("Upload completed")
        })
        
        task.observe(.failure, handler: { (snapshot: FIRStorageTaskSnapshot) in
            print("Upload failure")
            if let error = snapshot.error {
                print("Error uploading to GS: \(error.localizedDescription)")
            }
        })
    }
    
    /** Fetch the asset's download URL */
    func fetch(_ filename: String, type: object, completion:@escaping (URL)->()) {
        // retrieve file from storage and return link
        storagePath(type).child(filename + type.fileExtension()).downloadURL { (url, error) in
            if let error = error {
                print("Error fetching object from GS bucket: \(error.localizedDescription)")
            } else if let url = url {
                print("url download: \(url.absoluteString)")
                completion(url)
            }
        }
    }
    
    /**
     Get observed single event JSON object by ID
     */
    func fetch(objectID: String, object: object, completion:@escaping (FIRDataSnapshot?)->()) {
        // Get the computer reference structure and fire observation to Firebase
        databasePath(object).child(objectID).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            // Check to see if the reference exists, otherwise return nil
            if (snapshot.exists()) {
                completion(snapshot)
            } else {
                completion(nil)
            }
        })
    }
    
    private let moderatorKey = "moderator"
    /** Indicates if user is a moderator */
    func isModerator(_ completion: @escaping (Bool)->()) {
        database.child(moderatorKey).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let moderators = snapshot.value as? [String: Bool] {
                if let flag = moderators[self.uid] {
                    completion(flag)
                } else {
                    completion(false)
                }
            } else {
                print("Cannot access moderators list")
                completion(false)
            }
        })
    }
}

// MARK: Extensions

extension FIRStorageMetadata {
    /**
     Returns the absolute path on Storage
     */
    var storageURL: String {
        get {
            return FIR.manager.storage.child(self.path!).description
        }
    }
}

extension UIImageView {
    /**
     Load an image from Google Storage and layover busy indicator over imageView during load
     */
    func loadImageFromGS(url: URL, placeholderImage placeholder: UIImage?) {
        let storagePath: FIRStorageReference = FIR.manager.storage.child(url.path)

        // Initiate image download with "task" progress indicator if not already cached
        if let task = self.sd_setImage(with: storagePath, placeholderImage: placeholder) {
            // Setup progress observers
            task.observe(.progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print("Image \(percentComplete)% completed loading")
            })
            
            task.observe(.success, handler: { (snapshot: FIRStorageTaskSnapshot) in
                print("Image download observed completion")
            })
            
            task.observe(.failure, handler: { (snapshot: FIRStorageTaskSnapshot) in
                print("Image download observed failure")
                if let error = snapshot.error {
                    print("Error loading image from GS: \(error.localizedDescription)")
                }
                
            })
        } else {
            // Image is cached
        }
    }
}


