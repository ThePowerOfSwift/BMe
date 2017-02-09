//
//  Image.swift
//  BMe
//
//  Created by Lu Ao on 2/8/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Image: JSONObject {
    // Properties
    override class var object: FIR.object {
        get {
            return FIR.object.image
        }
    }
    private(set) var userProfile: UserProfile?
    private(set) var timestamp: String?
    /** URL to image Storage.  Needed to build storage reference (e.g. for sd_image loading)*/
    private(set) var storageURL: URL?
    private var uid: String?
    
    /** Retrieve the user profile */
    func userProfile(completion: @escaping (UserProfile)->()) {
        if let uid = uid {
            UserProfile.get(uid, completion: { (profile) in
                completion(profile!)
            })
        }
    }
    
    /** Initializer with a FIR snapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
        if let uid = json[keys.uid] as? String {
            self.uid = uid
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
        if let storageURL = json[keys.storageURL] as? String,
            let url = URL (string: storageURL){
            self.storageURL = url
        }
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Image)->()) {
        super.get(ID: ID, object: object) { (snapshot) in
            // return initialized object
            completion(Image(snapshot))
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
        static let storageURL = "storageURL"
    }
}
