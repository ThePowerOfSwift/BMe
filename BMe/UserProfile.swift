//
//  UserMeta.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

/**
 Publicly accessible user profile
 */
class UserProfile: JSONObject {
    
    override class var object: FIR.object {
        get {
            return FIR.object.userProfile
        }
    }

    /** User's unique ID */
    var uid: String? {
        get {
            // ID is already processed by superclass.
            // Return it as the user ID
            return self.ID
        }
    }
    
    // Properties
    /** User's profile photo URL */
    var avatarURL: URL? {
        get {
            return self.avatarURL
        }
        set {
            // The current user can only change their own profile
            if (self.uid == UserAccount.currentUser.uid), let uid = uid {
                UserProfile.firebasePath(uid).updateChildValues([keys.avatarURL: newValue?.absoluteString as AnyObject])
            }
        }
    }
    
    /** User's display name */
    var username: String? {
        get {
            return self.username
        }
        set {
            // The current user can only change their own profile
            if (self.uid == UserAccount.currentUser.uid), let uid = uid {
                UserProfile.firebasePath(uid).updateChildValues([keys.username: newValue as AnyObject])
            }
        }
    }
    
    /** Creation timestamp (immutable) */
    private(set) var timestamp: Date?
    
    //MARK: - Methods
    
    /** Initializes UserProfile object with FIRDataSnapshot */
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)

        if let avatarURL = json[keys.avatarURL] as? String {
            self.avatarURL = URL(string: avatarURL)
        }
        if let username = json[keys.username] as? String {
            self.username = username
        }
        if let timestamp = json[keys.timestamp] as? String {
            self.timestamp = timestamp.toDate()
        }
    }
    
    /**
     Gets the UserProfile for a given UID returns the object in completion block
     */
    class func get(_ UID: String, completion:@escaping (UserProfile)->()) {
        super.get(UID, object: object) { (snapshot) in
            // return initialized object
            completion(UserProfile(snapshot))
        }
    }
    
    /** 
     Creates a new user profile
     */
    class func create(UID: String, username: String) {
        // Check that user doesn't exist
        UserProfile.firebasePath(UID).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                // STOP as user profile already exists
                print("Error: user already exists")
            } else {
                let json = [keys.username: username as AnyObject,
                            keys.timestamp: Date().toString() as AnyObject]
                UserProfile.firebasePath(UID).setValue(json)
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
        return FIR.manager.databasePath(object).child(uid)
    }
    
    /** Keys used to locate JSON values */
    struct keys {
        static let avatarURL = "avatarURL"
        static let username = "username"
        static let timestamp = "timestamp"
    }
}
