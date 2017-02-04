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

    struct Key {
        static var object = "votebooth"
        static var timestamp = "timestamp"
        static var contentType = "contentType"
        static var matchup = "matchup"
        static var posts = "posts"
        static var votes = "votes"
    }
    
    struct Matchup {
        let ID: String
        let timestamp: String
        let posts: [String: AnyObject?]
    }
    
    static var database: FIRDatabaseReference = FIRManager.shared.database
    static var imageQueue = database.child(Key.object)
    static var matchupQueue = database.child(Key.object).child(Key.matchup)
    
    /**
     Submit a photo for voting
     */
    class func submitPost(_ ID: String) {
        
        // construct queue data to push
        // queue/(ID)/(metadata)
        let metadata = [Key.contentType : ContentType.post.string() as AnyObject,
                        Key.timestamp: Date().toString() as AnyObject]
        let object = [ID : metadata]
        
        // add to (database) queue
        // ~/votebooth
        JSONStack.queue(object: object as AnyObject , database: VoteBooth.imageQueue)
        
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
                let timestamp = data[Key.timestamp] as! String
                let posts = data[Key.posts] as! [String: AnyObject?]
                
                let matchup = Matchup(ID: snap.key, timestamp: timestamp, posts: posts)
                
                completion(matchup)
            }
        })
    }
    
    /** 
     Report results of vote-off
     */
    class func result(matchID: String, winnerID: String) {
        
        let meta = [Key.timestamp: Date().toString()]
        // votebooth/matchup/(key)/posts/(winner key)/votes/
        VoteBooth.matchupQueue.child(matchID).child(Key.posts).child(winnerID).child(Key.votes).child(UserAccount.currentUser.uid!).setValue(meta)
    }
    
    /** 
     Creates a matchup between given objects and add it to the database
     */
    private class func createMatchup(_ first: FIRDataSnapshot, _ second: FIRDataSnapshot) {
        // Create a matchup and insert into matchup bucket
        // ~/matchup/(key)/posts/(first.key)/etc
        let posts = [first.key: first.value, second.key: second.value]
        let metadata: [String: Any] = [Key.timestamp: Date().toString(),
                                       Key.posts: posts]

        // add to (database) queue
        VoteBooth.matchupQueue.childByAutoId().setValue(metadata)
    }
    
    class func remove(_ matchID: String) {
        VoteBooth.matchupQueue.child(matchID).removeValue()
    }
}

// Move to FIRManager
/** 
 Class that creates and manages a 'queue' in JSON
 Queue is stored in a sub path /queue
 Count of the queue is maintained by adding and removing timestamped children under /queue/count
 */
class JSONStack {
    
    struct Key {
        static var object = "queue"
        static var timestamp = "timestamp"
    }
    
    /**
     Queue object onto JSON stack
     */
    class func queue(object: AnyObject, database: FIRDatabaseReference) {
        // Add object to stack
        // Path: ~/queue
        database.child(Key.object).updateChildValues(object as! [AnyHashable : Any])
    }
    
    /**
     Pop next object from JSON stack FIFO
     */
    class func popFIFO(database: FIRDatabaseReference, completion:@escaping (FIRDataSnapshot?)->()) {
        // append "queue" to JSON path
        let database = database.child(Key.object)
        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            // test if empty (then return nil)
            if (snapshot.childrenCount < 1) || (!snapshot.exists()) {
                completion(nil)
            } else { // otherwise pop from queue and send to handler
                // get first child
                var objectToPop: FIRDataSnapshot?
                for snapChild in snapshot.children {
                    if let snapChild = snapChild as? FIRDataSnapshot {
                        objectToPop = snapChild
                    }
                    break
                }
                if let objectToPop = objectToPop {
                    // Get key ID
                    let key = objectToPop.key
                
                    // pop from queue & return
                    database.child(key).removeValue()
                    completion(objectToPop)
                } else {
                    print("Error, tried to pop item off queue; resulted in nil error")
                }
            }
        })
    }
    
    /** 
     Count the number of items in queue.  Implemented by counting the number of children under /queue
     */
    class func count(database: FIRDatabaseReference, completion:@escaping (UInt)->()) {
        database.child(Key.object).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
    }
}



