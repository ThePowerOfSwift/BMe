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
    private (set) var userPosts = [String: Any]()
    private (set) var postRefId = String()
    private (set) var post = [String: String]()
    private (set) var arrayOfPost = [[String: String]]()
    
    /** Initializes Post object using FIR snapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        self.userPosts = snapshot.value as! [String: Any]
        //TODO: What if there is huge amount of post?? Do the computing/sort as array in the cloud??
        for post in self.userPosts{
            self.arrayOfPost.append(post.value as! [String : String])
        }
    }
    
    
    /** Gets the Post for a given ID */
    class func getUserPost(UID: String, completion:@escaping (UserPost)->()) {
        super.get(UID, object: object) { (snapshot) in
            let userPost = UserPost(snapshot)
            completion(userPost)
        }
    }
    //Need Post ID & User Id
    
    
    //Get an array of Post from server
    
    /**
    Update post information towars a user
     
     - Parameter    PostID: String 
     - Parameter    uID: String
    */
    class func addPostToUser(PostID: String, uID: String, completion: (_ postRef: String) -> ()) {
        let orderId = FIR.manager.databasePath(object).childByAutoId().key
        let json : [String: AnyObject?] = [keys.type: "original" as AnyObject,
                                           keys.postid: PostID  as AnyObject,
                                           keys.status: "On"  as AnyObject]
        FIR.manager.databasePath(object).child(uID).child(orderId).setValue(json)
        completion(orderId)
    }
    
    
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

