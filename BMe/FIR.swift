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

    func databasePath(_ object:object) -> FIRDatabaseReference? {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return FIR.manager.database.child(object.key())
    }
    
    func storagePath(_ object: object) -> FIRStorageReference? {
        // Return path structure for given object
        // Current structure: ~/<object>/...
        return FIR.manager.storage.child(object.key())
    }
    
    // save to storage + associated json object to db
    func put(file data: Data, object: object) {
        // put file on storage
        // put file info on database
        // TODO: complete
    }
    
    // get asset by ID and content type from storage
    func fetch(_ filename: String, type: object, completion:(URL?)->()) {
        // retrieve file from storage and return link
        // TODO: complete
    }
    
    /**
     Get observed single event JSON object by ID
     */
    func get(objectID: String, object: object, completion:@escaping (FIRDataSnapshot?)->()) {
        // Get the computer reference structure and fire observation to Firebase
        if let database = FIR.manager.databasePath(object) {
            database.child(objectID).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                // Check to see if the reference exists, otherwise return nil
                if (snapshot.exists()) {
                    completion(snapshot)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    /**
     Firebase object types
     */
    enum object {
        // list object types
        case image

        // initialized based on object type
        init(_ type: String) {
            self = .image
        }
        
        init(object: JSONObject) {
            self = .image
        }
        
        func key() -> String {
            return "image"
        }
        
        func contentType() -> String {
            return "image/jpeg"
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
        FIR.manager.get(objectID: ID, object: object) { (snapshot) in
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
    // TODO: edit
    var contentType: ContentType?
    var downloadURL: URL?
    var gsURL: URL?
    var uid: String?
    var meta: [String: AnyObject?]?

    // Initializer
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        //TODO: rest of initialization
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Image_new)->()) {
        super.get(ID: ID, object: object) { (snapshot) in
            // return initialized object
            completion(Image_new(snapshot))
        }
    }
    
    //TODO: complete
    class func save() {
        // save image 
    }
    
    // Keys for dictionary that holds JSON properties
    // TODO: edit
    struct keys {
        static let uid = "uid"
    }
}
