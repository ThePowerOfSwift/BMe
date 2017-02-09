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

/** 
 Template class for Firebase JSON objects.
 Each JSON object requires:
 - a unique ID (Key)
 - a dictionary that contains object properties retrieved from database
 - an object (type) saved in the dictionary with the key "object" (etc. = "image")
 */
class JSONObject: NSObject {

    // JSON Object type
    class var object: FIR.object {
        get {
            assert(false, "Must override this property with FIR.object type")
            return FIR.object.image
        }
    }

    // Instance Properties
    // Unique identifier for the object
    let ID: String
    // JSON dictionary that contains object properties
    let json: [String: AnyObject?]
    
    // Create object with snapshot
    init(_ snapshot: FIRDataSnapshot) {
        ID = snapshot.key
        json = snapshot.value as! [String: AnyObject?]
    }
    
    // Helper function to retrieve JSON object from database
    // Should be wrapped by subclass with a static FIR.object type
    class func get(ID: String, object: FIR.object, completion:@escaping (FIRDataSnapshot)->()) {
        FIR.manager.fetch(json: ID, object: object) { (snapshot) in
            if let snapshot = snapshot {
                completion(snapshot)
            }
        }
    }
}

class Image_new: JSONObject {
    // Properties
    override class var object: FIR.object {
        get {
            return FIR.object.image
        }
    }
    private(set) var userProfile: UserProfile?
    private(set) var timestamp: String?
    private(set) var url: String?

    // Initializer
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
        if let uid = json[keys.uid] as? String {
            UserProfile.get(uid, completion: { (profile) in
                self.userProfile = profile
            })
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
        FIR.manager.fetch(ID, type: Image_new.object) { (url) in
            self.url = url.absoluteString
        }
        
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Image_new)->()) {
        super.get(ID: ID, object: object) { (snapshot) in
            // return initialized object
            completion(Image_new(snapshot))
        }
    }
    
    // Helper function to save Image to storage and database
    class func save(image: Data) -> String {
        // save image & return filename/ID
        return FIR.manager.put(file: image, object: FIR.object.image)
    }
    
    // Keys for dictionary that holds JSON properties
    struct keys {
        static let uid = "uid"
        static let timestamp = "timestamp"
    }
}


class Post_new: JSONObject {
    // Properties
    override class var object: FIR.object {
        get {
            return FIR.object.post
        }
    }

    var userProfile: UserProfile?
    var timestamp: String?
    // TODO: add asset type
    var asset: Image_new?
    
    // Initializer
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        // TODO: Put else to capture fails and return error
        if let uid = json[keys.uid] as? String {
            UserProfile.get(uid, completion: { (profile) in
                self.userProfile = profile
            })
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
        if let assetID = json[keys.assetID] as? String {
            Image_new.get(ID: assetID, completion: { (image) in
                self.asset = image
            })
        }
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Post_new)->()) {
        super.get(ID: ID, object: object) { (snapshot) in
            // return initialized object
            completion(Post_new(snapshot))
        }
    }
    
    // Helper function to create posts
    // TODO: Work together with progress func/bar
    class func create(assetID: String, assetType: FIR.object) {
        // Construct json to save
        let json: [String: AnyObject?] = [keys.uid: FIR.manager.uid as AnyObject,
                                          keys.timestamp: Date().toString()  as AnyObject,
                                          keys.assetID: assetID  as AnyObject,
                                          keys.assetObject: assetType.key()  as AnyObject]
        
        // Save image
        FIR.manager.databasePath(object).childByAutoId().setValue(json)
    }
    
    // Keys for dictionary that holds JSON properties
    struct keys {
        static let uid = "uid"
        static let timestamp = "timestamp"
        static let assetID = "assetID"
        static let assetObject = "assetObject"
    }
}
