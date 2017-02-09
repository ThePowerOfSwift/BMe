//
//  FIR.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/4/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase

/**
 Firebase Storage and Database wrapper class
 */
class FIR: NSObject {
    static let manager = FIR()
    private override init() {
        super.init()
    }
    
    // Firebase reference properties
    static var storagePrefix = "gs://"
    private(set) var database = FIRDatabase.database().reference()
    private(set) var storage = FIRStorage.storage().reference(forURL: storagePrefix + FIRApp.defaultApp()!.options.storageBucket)
    // User ID
    private(set) var uid = FIRAuth.auth()!.currentUser!.uid

    func databasePath(_ object:object) -> FIRDatabaseReference {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return database.child("dev").child(object.key())
    }
    
    func storagePath(_ object: object) -> FIRStorageReference {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return storage.child("dev").child(object.key())
    }
    
    // save to storage + associated json object to db
    func put(file data: Data, object: object) -> String {
        // Put file on storage
        // Get unique path using UID as root
        let path = storagePath(object)
        let filename = database.childByAutoId().key
        let fileExtension = object.fileExtension()

        // Construct meta data for file upload
        let metadata = FIRStorageMetadata()
        metadata.contentType = object.contentType()
        metadata.customMetadata = ["uid":uid]
        
        // Put to Storage
        path.child(filename + fileExtension).put(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
                //TODO: stop
            }
            else {
                // Write object info to database
                let json = ["uid": self.uid,
                            "object": object.key(),
                            "timestamp": Date().toString()]
                self.databasePath(object).child(filename).setValue(json)
            }
        }
        
        return filename
    }
    
    // get asset by ID and content type from storage
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
    func fetch(json objectID: String, object: object, completion:@escaping (FIRDataSnapshot?)->()) {
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
    
    /**
     Firebase object types
     */
    enum object {
        // list object types
        case image, post, video, matchup

        func key() -> String {
            switch self {
            case .image:
                return "image"
            case .post:
                return "post"
            case .video:
                return "video"
            case .matchup:
                return "matchup"
            }
        }
        
        func contentType() -> String {
            switch self{
                case .image:
                return "image/jpeg"
                case .video:
                return "video/mp4"
            default:
                return ""
            }
        }
        
        func fileExtension() -> String {
            switch self {
            case .image:
                return ".jpeg"
            case .video:
                return ".mp4"
            default:
                return ""
            }
        }
    }
}

// MARK:- Extensions

extension FIRStorageMetadata {
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
        //        self.sd_setImage(with: storagePath)
        
        
        if let task = self.sd_setImage(with: storagePath, placeholderImage: placeholder) {
            // Setup progress indicator
            //            let busyIndicator = UIActivityIndicatorView(frame: self.bounds)
            //            self.addSubview(busyIndicator)
            //            busyIndicator.startAnimating()
            //
            //            task.observe(.progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
            //                if let progress = snapshot.progress {
            //                    let completed: CGFloat = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
            ////                    self.alpha = completed
            //                }
            //            })
            //            task.observe(.success, handler: { (snapshot: FIRStorageTaskSnapshot) in
            ////                self.alpha = 1
            //                busyIndicator.removeFromSuperview()
            //            })
            //            task.observe(.failure, handler: { (snapshot: FIRStorageTaskSnapshot) in
            //                if let error = snapshot.error {
            //                    print("Error loading image from GS \(error.localizedDescription)")
            //                }
            //                busyIndicator.removeFromSuperview()
            //            })
        }
    }
}


