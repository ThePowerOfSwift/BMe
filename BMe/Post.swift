//
//  Post.swift
//  BMe
//
//  Created by Lu Ao on 2/8/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

/** 
 Class that represents a post made by a user.  A post can contain several elements, such as an image etc.
 */
class Post: JSONObject {
    /** JSON Object type that identifies Post on Firebase */
    override class var object: FIR.object {
        get {
            return FIR.object.post
        }
    }

    /** Timestamp when post was created */
    private(set)var timestamp: String?
    /** ID to track the post's asset */
    private var assetID: String?
    /** Creators user ID */
    private var uid: String?
    private(set) var hashtag: String?
    
    /** Returns the post's asset */
    func asset(completion: @escaping (Image)->()) {
        if let assetID = assetID {
            Image.get(ID: assetID, completion: { (image) in
                completion(image)
            })
        }
    }
    
    /** Returns the URL to the post's asset */
    // TODO: change to assetStorageURL
    func assetURL(completion: @escaping (URL) -> ()) {
        self.asset { (image) in
                completion(image.storageURL!)
        }
    }
    
    /** Returns the creator's UserProfile */
    func userProfile(completion: @escaping (UserProfile)->()) {
        if let uid = uid {
            UserProfile.get(uid, completion: { (profile) in
                completion(profile)
            })
        }
    }
    
    /** Initializes Post object using FIR snapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        if let uid = json[keys.uid] as? String {
            self.uid = uid
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
        if let assetID = json[keys.assetID] as? String {
            self.assetID = assetID
        }
        if let hashtag = json[keys.hashtag] as? String{
            self.hashtag = hashtag
        }
    }
    
    /** Gets the Post for a given ID */
    class func get(ID: String, completion:@escaping (Post)->()) {
        super.get(ID, object: object) { (snapshot) in
            // return initialized object
            completion(Post(snapshot))
        }
    }
    
    /** Creates a new post */
    class func create(assetID: String, assetType: FIR.object, hashtag: String) -> String {
        // Construct json to save
        let json: [String: AnyObject?] = [keys.uid: FIR.manager.uid as AnyObject,
                                          keys.timestamp: Date().toString()  as AnyObject,
                                          keys.assetID: assetID  as AnyObject,
                                          keys.assetObject: assetType.key()  as AnyObject,
                                          keys.hashtag: hashtag as AnyObject]
        
        // Save image
        let filename = FIR.manager.databasePath(object).childByAutoId().key
        FIR.manager.databasePath(object).child(filename).setValue(json)
        return filename
    }
    
    /** Database keys */
    struct keys {
        static let uid = "uid"
        static let timestamp = "timestamp"
        static let assetID = "assetID"
        static let assetObject = "assetObject"
        static let hashtag = "hashtag"
    }
}
