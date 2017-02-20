//
//  Like.swift
//  BMe
//
//  Created by Lu Ao on 2/19/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//  Like
//      - PosID
//           - Count: Int
//           - uid: true/false
// Check moderator -- for check if already liked
// match up -- for realtime count update

import UIKit
import FirebaseDatabase

class Like: JSONObject {
    override class var object: FIR.object {
        get {
            return FIR.object.like
        }
    }
    
    private (set) var likeCount = 0
    private (set) var usersID = [String]()
    
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
    }
    
    /**
    Updating like information when performing like action a post with given postID
     - Parameter postID: String
     - Parameter uID: Sting
    */
    class func updateLikeToPost(postID: String, uID: String, completion: () -> ()) {
        let likeCount = 0//Should intergrate with like check function
        let json : [String: AnyObject?] = [keys.type: "original" as AnyObject,
                                           keys.status: "On"  as AnyObject]
        FIR.manager.databasePath(object).child(uID).child(postID).setValue(json)
    }
    
    
    
    /**
    Retrieve like infomation(count, array of users(uid) like the that post
    */
    
    
    /** Database keys */
    struct keys {
        static let uid = "uid"
        static let timestamp = "timestamp"
        static let assetID = "assetID"
        static let assetObject = "assetObject"
        static let hashtag = "hashtag"
        static let type = "type"
        static let postid = "postid"
        static let status = "status"
    }
    
}
