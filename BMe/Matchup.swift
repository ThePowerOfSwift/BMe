//
//  Matchup.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

/**
 Matchup posts against each other!
 */
class Matchup: JSONObject {
    // Properties
    override class var object: FIR.object {
        get {
            return FIR.object.matchup
        }
    }
    
    // first post
    private var postAID: String?
    // vs. second post
    private var postBID: String?
    // total votes for A
    private(set) var countVoteA: Int?
    // total votes for B
    private(set) var countVoteB: Int?
    // has user already voted flag
    private(set) var didVote : Bool?
    private(set) var timestamp: String?
    
    /** 
     Retrieve post objects
     */
    //TODO: clean up code
    func posts(completion:@escaping (Post, Post)->()) {
        if let postAID = self.postAID, let postBID = self.postBID {
            Post.get(ID: postAID, completion: { (post) in
                let postA = post
                
                Post.get(ID: postBID, completion: { (postB) in
                    let postB = postB
                    completion(postA, postB)
                })
            })
        }
    }
    
    // Initializer
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
        // Load properties and instances
        if let postAID = json[keys.postAID] as? String {
            self.postAID = postAID
        }
        if let postBID = json[keys.postBID] as? String {
            self.postBID = postBID
        }
        if let countVoteA = json[keys.countVoteA] as? String {
            self.countVoteA = Int(countVoteA)
        }
        if let countVoteB = json[keys.countVoteB] as? String {
            self.countVoteB = Int(countVoteB)
        }
        // Compute if the user has voted for this matchup before or not
        let voted = json[keys.voted] as? [String: Bool] ?? [:]
        if let _ = voted[FIR.manager.uid] {
            self.didVote = true
        } else {
            self.didVote = false
        }
        
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp
        }
    }
    
    // Helper function to retrieve Image JSON object from database
    class func get(ID: String, completion:@escaping (Matchup)->()) {
        super.get(ID, object: object) { (snapshot) in
            // return initialized object
            completion(Matchup(snapshot))
        }
    }
    
    // Helper function to create matchups
    class func create(postAID: String, postBID: String) {
        // Construct json to save
        let json: [String: AnyObject?] = [keys.timestamp: Date().toString()  as AnyObject,
                                          keys.postAID: postAID as AnyObject,
                                          keys.postBID: postBID as AnyObject,
                                          keys.countVoteA: 0 as AnyObject,
                                          keys.countVoteB: 0 as AnyObject,
                                          keys.voted: [:] as AnyObject]
        
        // Write json to DB
        FIR.manager.databasePath(object).childByAutoId().setValue(json)
    }
    
    /** 
     Cast a vote for a Post (A or B).  If associated uid (user) can only cast a vote once.
     */
    func vote(_ forPost: voteFor) {
        FIR.manager.databasePath(Matchup.object).child(self.ID).runTransactionBlock({ (currentData) -> FIRTransactionResult in
            
            // Check matchup exists and fetch data edit
            if var matchup = currentData.value as? [String: AnyObject]{
                let uid = FIR.manager.uid

                // Look up current value
                var voteCount = matchup[forPost.key()] as? Int ?? 0
                var voted = matchup[keys.voted] as? [String: Bool] ?? [:]
                
                // User already voted
                if let _ = voted[uid] {
                    print("Matchup: You already voted!")
                    return FIRTransactionResult.success(withValue: currentData)
                }

                // Cast a vote for the user
                    voteCount += 1
                    voted[uid] = true
            
                // Update data to be committed
                matchup[forPost.key()] = voteCount as AnyObject
                matchup[keys.voted] = voted as AnyObject
                
                // Commit
                currentData.value = matchup
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print("Error updating matchup vote: \(error.localizedDescription)")
            } else if let snapshot = snapshot, committed {
            // Update object properties
                let matchup = Matchup(snapshot)
                self.countVoteA = matchup.countVoteA
                self.countVoteB = matchup.countVoteB
                self.didVote = matchup.didVote
            }
        }
    }

    /**
     Keys for Matchup database object
     */
    struct keys {
        static let timestamp = "timestamp"
        static let postAID = "postAID"
        static let postBID = "postBID"
        static let countVoteA = "countVoteA"
        static let countVoteB = "countVoteB"
        static let voted = "voted"
    }
    
    /** 
     Enum type used to cast votes for A or B
     */
    enum voteFor {
        case A, B
        
        func key() -> String {
            switch self {
            case .A:
                return keys.countVoteA
            case .B:
                return keys.countVoteB
            }
        }
    }
    
    // MARK: Submission methods
    
    /**
     Submit a photo for voting
     */
    class func submitPost(_ postID: String){
        let json = [postID: "" as AnyObject?]
        JSONStack.queue(object: json, database: FIR.manager.databasePath(object))
        
        // Apply matchup logic
        updateQueue()
    }
    
    /**
     Apply matchup rules/logic:
     Takes free images in queue and puts it in matchup queue
     */
    private class func updateQueue() {
        // if there are two or more objects in queue, dequeue them and create a matchup
        JSONStack.popFIFO(2, database: FIR.manager.databasePath(object), completion: { (result) in
            // Create matchup with two objects popped from queue
            if (result.count == 2) {
                Matchup.create(postAID: result[0].keys.first!, postBID: result[1].keys.first!)
            }
        })
    }
    
    /**
     Apply service rules/logic:
     Returns assets for vote-off.
     */
    class func serve(completion:@escaping (Matchup)->()) {
        // TODO: can we move "FIR.manager.databasePath(object)" as superclass (JSONObject) computed property
        let database = FIR.manager.databasePath(object)
        
        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            // randomize the returned matchup
            let random = Int(arc4random_uniform(UInt32(snapshot.childrenCount)))
            print("random: \(random)")
            
            if let matchups = snapshot.value as? [String: AnyObject?] {
                // Return the matchup indexed at randomized number
                let key = Array(matchups.keys)[random]
                let matchup = Matchup(snapshot.childSnapshot(forPath: key))
                
                completion(matchup)
            }
        })
    }
    
    class func remove(_ matchID: String) {
        let database = FIR.manager.databasePath(object).child(matchID)
        
        database.runTransactionBlock { (currentData) -> FIRTransactionResult in
            // remove and commit
            if let _ = currentData.value as? [String: AnyObject?] {
                currentData.value = nil
                return FIRTransactionResult.success(withValue: currentData)
            }
            
            return FIRTransactionResult.success(withValue: currentData)
        }
    }
}

