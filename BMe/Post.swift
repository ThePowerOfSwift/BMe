//
//  Post.swift
//  BMe
//
//  Created by Lu Ao on 2/8/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Post: JSONObject {
    // Properties
    override class var object: FIR.object {
        get {
            return FIR.object.post
        }
    }
    var userProfile: UserProfile?
    var timestamp: String?
    // TODO: add asset type
    private var assetID: String?
    private var uid: String?
    
    func asset(completion: @escaping (Image)->()) {
        if let assetID = assetID {
            Image.get(ID: assetID, completion: { (image) in
                completion(image) //get in hand in completion handler
            })
        }
    }
    
    func assetURL(completion: @escaping (URL) -> ()) {
        self.asset { (image) in
            image.url(completion: { (url) in
                completion(url)
            })
        }
    }
    
    func userProfile(completion: @escaping (UserProfile)->()) {
        if let uid = uid {
            UserProfile.get(uid, completion: { (profile) in
                completion(profile!)
            })
        }
    }
    
    
    
    // Initializer
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        // TODO: Put else to capture fails and return error
        if let uid = json[keys.uid] as? String {
            self.uid = uid
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
        if let assetID = json[keys.assetID] as? String {
            self.assetID = assetID
        }
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Post)->()) {
        super.get(ID: ID, object: object) { (snapshot) in
            // return initialized object
            completion(Post(snapshot))
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
