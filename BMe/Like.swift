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
    private (set) var didLike = Bool()
    
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        let countInfo = snapshot.value as! [String:Any]
        self.likeCount = countInfo["count"] as! Int
        //Save all userID liked the post to an array
    }
    
    /**
    Create like information when performing like action a post with given postID
     - Parameter postID: String
     - Parameter uID: Sting
    */
    class func createLikeToPost(postID: String, uID: String, completion: () -> ()) {
        let likeCount = 1//Should intergrate with like check function
        let json : [String: AnyObject?] = [keys.count: likeCount as AnyObject,
                                           uID:  true as AnyObject]
        FIR.manager.databasePath(object).child(postID).setValue(json)
    }
    
    
    
    /**
    Retrieve like infomation(count, array of users(uid) like the that post
    */
    class func get(postID: String, completion:@escaping (Like)->()) {
        super.get(postID, object: object) { (snapshot) in
            // return initialized object
            completion(Like(snapshot))
        }
    }
    
    
   class func like(forPostID: String) {
        // Update instance properties for immediate feedback to user
        // This like is updated posthumously in the completion handler below
        //Like.didLike = true
        // Attempt to update database
        FIR.manager.databasePath(Like.object).child(forPostID).runTransactionBlock({ (currentData) -> FIRTransactionResult in
           print("post:\(forPostID)")
            // Check matchup exists and fetch data edit
            if var likeInfo = currentData.value as? [String: AnyObject]{
                let uid = FIR.manager.uid
                // Look up current value
                var likeCount = likeInfo[keys.count] as? Int ?? 0
                var likedList = likeInfo[keys.users] as? [String:Bool]
                var isliked = likedList?[uid]
                
                // User already Liked, decrease total like
                if let didLiked = isliked {
                    if didLiked{
                        likeCount -= 1
                        isliked = false
                    }
                    else{
                        likeCount += 1
                        isliked = true
                    }
                }
                else{
                    likeCount += 1
                    isliked = true
                }
                // Update data to be committed
                
                likedList?[uid] = isliked
                likeInfo[keys.count] = likeCount as AnyObject
                likeInfo[keys.users] = likedList as AnyObject
                // Commit
                currentData.value = likeInfo
                return FIRTransactionResult.success(withValue: currentData)
            }
            else{
                let uid = FIR.manager.uid
                let likedList: [String:Bool] = [uid: true]
                let likeInfo : [String: AnyObject?] = [keys.count: 1 as AnyObject,
                                                   keys.users:  likedList as AnyObject]
                // Commit
                currentData.value = likeInfo
                return FIRTransactionResult.success(withValue: currentData)
            }
            //return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print("Error updating matchup vote: \(error.localizedDescription)")
            } 
        }
    }
    
    
    
    /** Database keys */
    struct keys {
        static let uid = "uid"
        static let users = "users"
        static let postid = "postid"
        static let status = "status"
        static let count = "count"
    }
    
}
