//
//  UserMeta.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserProfile: NSObject {
    let uid: String?
    let timestamp: Date?
    let avatarURL: URL?
    let username: String?
    let raincheck: [String: AnyObject]?
    let heart: [String: AnyObject]?
    
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

        // TODO: can you replace "dictionary" with .value?  and delete dictionary extension
        let values = snapshot.dictionary
        self.avatarURL = URL(string: (values[Key.avatarURL] as? String) ?? "") ?? nil
        self.timestamp = (values[Key.timestamp] as? String)?.toDate() ?? nil
        self.username = values[Key.username] as? String ?? nil
        self.raincheck = values[Key.raincheck] as? [String: AnyObject] ?? nil
        self.heart = values[Key.heart] as? [String: AnyObject] ?? nil
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
        return FIRManager.shared.database.child(Key.object).child(uid)
    }
}
