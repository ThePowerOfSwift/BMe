//
//  PrivacyCheck.swift
//  BMe
//
//  Created by Lu Ao on 3/11/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import Foundation
import FirebaseDatabase

// Treated as Retrieve global post feed for a user

class PrivacyCheck: NSObject {
    /** Singleton accessor */
    static let manager = PrivacyCheck()
    private override init() {
        super.init()
    }
    
    var posts: [Post] = []
    var isFetchingData = false
    var database = FIR.manager.databasePath(.post)
    var frnddatabase = FIR.manager.databasePath(.friends)
    var friends = [String:[String:Bool]]()
    var feedPost = [Post]()
    
    let fetchBatchSize = 10
    
    // For global Post feed:
    // 1. Grab all post
    // 2. Grab friend list for current user
    // 3. make privact chek 
    //
    func privacyCheck(postList: [Post], friendList: [String]){
        let uid = UserAccount.currentUser.uid!
        
        for post in postList{
            //Retrieve friend List using post owner's uid, i.e. post.uid
            if let list = self.friends[post.uid!]{
                if list[uid]!{
                    self.feedPost.append(post)
                }
            }
            else{
                Friends.get(UID: post.uid!, completion: { (Friends) in
                    self.friends[post.uid!] = Friends.firendList
                })
            }
        }
    
    }
    
    func fetchMoreDatasource() {
        if !isFetchingData {
            isFetchingData = true
            
            // Get the "next batch" of posts
            // Request with upper limit on the last loaded post with a lower limit bound by batch size
            let lastPost = posts[posts.count - 1]
            database.queryEnding(atValue: lastPost.ID).queryLimited(toLast: UInt(fetchBatchSize)).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    // returns posts oldest to youngest, inclusive, so remove last child
                    // and reverse to revert to youngest to oldest order (or reverse and remove first child)
                    var ignoreFirst = true
                    for child in snapshot.children.reversed() {
                        if ignoreFirst { //ignore reference post and add the rest
                            ignoreFirst = false
                        }
                        else {
                            let post = Post(child as! FIRDataSnapshot)
                            // append data
                            self.posts.append(post)
                        }
                    }
                    self.isFetchingData = false
            })
        }
    }
    
}
