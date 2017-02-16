//
//  UsePost.swift
//  BMe
//
//  Created by Lu Ao on 2/15/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

/**
 Class that represents a post made by a user.  A post can contain several elements, such as an image etc.
 */
class UserPost: JSONObject {
    override class var object: FIR.object {
        get {
            return FIR.object.userPost
        }
    }
    
    private (set) var array = [String]()
    /** Initializes Post object using FIR snapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
        self.array = snapshot.value as! [String]
    }
    
    /** Gets the Post for a given ID */
    class func getUserPost(UID: String, completion:@escaping (UserPost)->()) {
        super.get(UID, object: object) { (snapshot) in
            // return initialized object
            completion(UserPost(snapshot))
        }
    }
    //Need Post ID & User Id
    
    
    //Get an array of Post from server
    
    
    //Update
    class func addPostToUser(PostID: String, uID: String, completion: () -> Void) -> Void{
        let newOrder = FIR.manager.databasePath(object).childByAutoId().key
        FIR.manager.databasePath(object).child(uID).child(newOrder).setValue(PostID)
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

