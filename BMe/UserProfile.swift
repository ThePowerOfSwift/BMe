//
//  UserMeta.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

// TODO: change to JSONObject subclass
class UserProfile: NSObject {
    var uid: String?
    var timestamp: Date?
    var avatarURL: URL?
    var username: String?
    
    //MARK: - Database keys
    struct Key {
        static let object = "userMeta"
        static let timestamp = "timestamp"
        static let avatarURL = "avatarURL"
        static let username = "username"
        static let raincheck = "raincheck"
        static let heart = "heart"
    }
    
    //MARK: - Methods
    init(_ snapshot: FIRDataSnapshot) {
        self.uid = snapshot.key

        if let values = snapshot.value as? [String: AnyObject?] {
            self.avatarURL = URL(string: (values[Key.avatarURL] as? String) ?? "") ?? nil
            self.timestamp = (values[Key.timestamp] as? String)?.toDate() ?? nil
            self.username = values[Key.username] as? String ?? nil
        }
    }
    
    /**
     Gets the UserProfile of a user given it's uid and returns in the completion block
     */
    class func get(_ uid: String, completion:@escaping (UserProfile?)->()) {
        firebasePath(uid).observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                let userProfile = UserProfile(snapshot)
                completion(userProfile)
            } else {
                print("Error: UserProfile for UID:\(uid) does not exist")
                completion(nil)
            }
        })
    }
    
    /**
     Retrieves the UserProfile for user that is currently logged in
     */
    class func currentUser(completion: @escaping (UserProfile?)->()) {
        UserProfile.get(UserAccount.currentUser.uid!, completion: { (userProfile) in
            completion(userProfile)
        })
    }
    
    /** 
     Returns the path (database reference) to the UserProfile of a given user
     */
    class func firebasePath(_ uid: String) -> FIRDatabaseReference {
        return FIR.manager.database.child(Key.object).child(uid)
    }
}
