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

    // MARK: Properties
    
    /** JSON object type */
    override class var object: FIR.object {
        get {
            return .matchup
        }
    }
    
    /** First post */
    private var postAID: String?
    /** vs. second post */
    private var postBID: String?
    /** total votes for A */
    private(set) var countVoteA: Int = 0
    /** total votes for B */
    private(set) var countVoteB: Int = 0
    /** User has already voted flag */
    private(set) var didVote : Bool?
    /** Creation timestamp */
    private(set) var timestamp: String?
    /** Hashtag*/
    private(set) var hashtag: String?
    
    // MARK: Lifecycle
    
    /** Initializes a match with FIR snapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        
        // Load properties and instances
        if let postAID = json[keys.postAID] as? String {
            self.postAID = postAID
        }
        if let postBID = json[keys.postBID] as? String {
            self.postBID = postBID
        }
        if let hashtag = json[keys.hashtag] as? String{
            self.hashtag = hashtag
        }
        
        self.countVoteA = json[keys.countVoteA] as? Int ?? 0
        self.countVoteB = json[keys.countVoteB] as? Int ?? 0
        
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
    
    // MARK: Instance methods
    /**
     Retrieve post objects
     */
    func posts(completion:@escaping (Post, Post)->()) {
        if let postAID = self.postAID, let postBID = self.postBID {
            Post.get(ID: postAID, completion: { (postA) in
                Post.get(ID: postBID, completion: { (postB) in
                    completion(postA, postB)
                })
            })
        }
    }
    
    /** Retrieve Matchup JSON object from database */
    class func get(ID: String, completion:@escaping (Matchup)->()) {
        super.get(ID, object: object) { (snapshot) in
            // return initialized object
            completion(Matchup(snapshot))
        }
    }
    
    /** Create a matchup */
    class func create(postAID: String, postBID: String, hashtag: String) {
        // Construct json to save
        let json: [String: AnyObject] = [keys.timestamp: Date().toString()  as AnyObject,
                                         keys.postAID: postAID as AnyObject,
                                         keys.postBID: postBID as AnyObject,
                                         keys.countVoteA: 0 as AnyObject,
                                         keys.countVoteB: 0 as AnyObject,
                                         keys.voted: [:] as AnyObject,
                                         keys.hashtag : hashtag as AnyObject]
        
        // Write json to DB
        FIR.manager.databasePath(object).childByAutoId().setValue(json)
    }
    
    /** Cast a vote for a Post (A or B).  If associated uid (user) can only cast a vote once. */
    func vote(_ forPost: voteFor) {
        // Update instance properties for immediate feedback to user
        // This matchup is updated posthumously in the completion handler below
        if (forPost == .A) {
            self.countVoteA += 1
        } else {
            self.countVoteB += 1
        }
        self.didVote = true

        // Attempt to update database
        FIR.manager.databasePath(Matchup.object).child(self.ID).runTransactionBlock({ (currentData) -> FIRTransactionResult in
            
            // Check matchup exists and fetch data edit
            if var matchup = currentData.value as? [String: AnyObject]{
                let uid = FIR.manager.uid

                // Look up current value
                var voteCount = matchup[forPost.key()] as? Int ?? 0
                var voted = matchup[keys.voted] as? [String: Bool] ?? [:]
                
                // User already voted, don't count this vote
                if let _ = voted[uid] {
                    print("Error: User already voted for match \(self.ID)!")
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

    // MARK: Types
    
    /** Keys for Matchup database object */
    struct keys {
        static let timestamp = "timestamp"
        static let postAID = "postAID"
        static let postBID = "postBID"
        static let countVoteA = "countVoteA"
        static let countVoteB = "countVoteB"
        static let voted = "voted"
        static let hashtag = "hashtag"
        static let queueKey = "key"
    }
    
    /** Enum type used to cast votes for A or B */
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
    
    // MARK: Class methods for submission
    
    // TODO: Change to queuePost
    /** 
     Submit a photo for voting.
     Queues with JSON object [keys.queueKey: postID]
     */
    class func submitPost(_ postID: String) {
        let json: [String: AnyObject] = [keys.queueKey: postID as AnyObject]
        JSONStack.queue(json: json, object: object)
        
        // Apply matchup logic
//        Disable for moderator
//        updateQueue()
    }
    
    /** Returns the reference/path to the items queued for matchup */
    class func queue() -> FIRDatabaseReference {
        return JSONStack.queueDatabase(object)
    }
    
    /**
     Apply service rules/logic:
     Returns assets for vote-off.
     */
    class func serveRandom(completion:@escaping (Matchup)->()) {
        // TODO: can we move "FIR.manager.databasePath(object)" as superclass (JSONObject) computed property
        let database = FIR.manager.databasePath(object)
        
        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            // randomize the returned matchup
            let random = Int(arc4random_uniform(UInt32(snapshot.childrenCount)))
            
            if let matchups = snapshot.value as? [String: AnyObject?] {
                // Return the matchup indexed at randomized number
                let key = Array(matchups.keys)[random]
                let matchup = Matchup(snapshot.childSnapshot(forPath: key))
                
                completion(matchup)
            }
        })
    }
    
    /** 
     Return an array of the daily matchups
     */
    class func dailyMatchups(completion:@escaping ([Matchup])->()) {
        let database = FIR.manager.databasePath(object)

        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            var arrayOfMatchups: [Matchup] = []
            
            for child in snapshot.children {
                if let child = child as? FIRDataSnapshot {
                    arrayOfMatchups.append(Matchup(child))
                }
            }
            completion(arrayOfMatchups)
        })
    }
    
    /** Delete a match given its ID */
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

