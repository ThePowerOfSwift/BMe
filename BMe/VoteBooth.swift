//
//  VoteBooth.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/30/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class VoteBooth: NSObject {

   
    
    struct Matchup {
        let ID: String
        let timestamp: String
        let posts: [String: AnyObject?]
    }
    
    static var database: FIRDatabaseReference = FIRManager.shared.database
    static var imageQueue = database.child(keys.object)
    static var matchupQueue = database.child(keys.object).child(keys.matchup)
    
    /**
     Submit a photo for voting
     */
    class func submitPost(_ ID: String) {
        
        // construct queue data to push
        // queue/(ID)/(metadata)
        let metadata = [keys.contentType : ContentType.post.string() as AnyObject,
                        keys.timestamp: Date().toString() as AnyObject]
        let object = [ID: metadata as AnyObject]
        
        // add to (database) queue
        // ~/votebooth
        JSONStack.queue(object: object, database: VoteBooth.imageQueue)
        
        // Update matchup bucket
        VoteBooth.update()
    }
    
    /** 
     Apply matchup rules/logic:
     Takes free images in queue and puts it in matchup queue
     */
    private class func update() {
        // if there are two or more objects in queue, dequeue them and create a matchup
        JSONStack.count(database: VoteBooth.imageQueue) { (count) in
            if (count > 1) {
                JSONStack.popFIFO(database: VoteBooth.imageQueue, completion: { (snapshot) in
                    if let firstObject = snapshot {
                        JSONStack.popFIFO(database: VoteBooth.imageQueue, completion: { (snapshot) in
                            if let secondObject = snapshot {
                                // Create matchup with two objects popped from queue
                                VoteBooth.createMatchup(firstObject, secondObject)
                            }
                        })
                    }
                })
            }
        }
    }

    /**
     Apply service rules/logic:
     Returns assets for vote-off.
     */
    class func serve(completion:@escaping (Matchup)->()) {
        // return matchup

        // Return first matchup
        // TODO: change rule
        VoteBooth.matchupQueue.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            var snap: FIRDataSnapshot?
            for snapChild in snapshot.children {
                if let snapChild = snapChild as? FIRDataSnapshot {
                    snap = snapChild
                }
                break
            }
            
            // return matchup struct/object
            if let snap = snap {
                let data = snap.value as! [String: AnyObject?]
                let timestamp = data[keys.timestamp] as! String
                let posts = data[keys.posts] as! [String: AnyObject?]
                
                let matchup = Matchup(ID: snap.key, timestamp: timestamp, posts: posts)
                
                completion(matchup)
            }
        })
    }
    
    /** 
     Report results of vote-off
     */
    class func result(matchID: String, winnerID: String) {
        
        let meta = [keys.timestamp: Date().toString()]
        // votebooth/matchup/(key)/posts/(winner key)/votes/
        VoteBooth.matchupQueue.child(matchID).child(keys.posts).child(winnerID).child(keys.votes).child(UserAccount.currentUser.uid!).setValue(meta)
    }
    
    /** 
     Creates a matchup between given objects and add it to the database
     */
    private class func createMatchup(_ first: FIRDataSnapshot, _ second: FIRDataSnapshot) {
        // Create a matchup and insert into matchup bucket
        // ~/matchup/(key)/posts/(first.key)/etc
        let posts = [first.key: first.value, second.key: second.value]
        let metadata: [String: Any] = [keys.timestamp: Date().toString(),
                                       keys.posts: posts]

        // add to (database) queue
        VoteBooth.matchupQueue.childByAutoId().setValue(metadata)
    }
    
    class func remove(_ matchID: String) {
        VoteBooth.matchupQueue.child(matchID).removeValue()
    }
    
    struct keys {
        static var object = "votebooth"
        static var timestamp = "timestamp"
        static var contentType = "contentType"
        static var matchup = "matchup"
        static var posts = "posts"
        static var votes = "votes"
    }
}




