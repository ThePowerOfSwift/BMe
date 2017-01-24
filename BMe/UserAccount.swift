//
//  User.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/2/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

/**
 UserAccount tracks and updates a user's account.  Model is based on FIRUser (since FIRUser is not directly editable).  Customized user data is implemented in UserProfile class
 */
class UserAccount: NSObject {
    
    // General reference
    private var userProfileReference: FIRDatabaseReference? {
        get {
            // Path: Database/<User Meta key>/<UID>/
            // TODO: refactor ContentType.userMeta.objectKey
            return FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(firUser.uid)
        }
    }

    // Model (from FIRUser)
    private var firUser: FIRUser
    
    
    var username: String? {
        get {
            return firUser.displayName
        }
        set {
            // Change firUser
            let changeRequest = firUser.profileChangeRequest()
            changeRequest.displayName = newValue
            changeRequest.commitChanges(){ (error) in
                if let error = error {
                    print("Error updating User display name: \(error.localizedDescription)")
                }
            }
            // Change UserProfile
            let data = [UserProfile.Key.username: newValue as AnyObject]
            userProfileReference?.updateChildValues(data)
        }
    }
    var email: String? {
        get {
            return firUser.email
        }
    }
    
    var avatarURL: URL? {
        get {
            // Returns the avatar's GS URL
            return firUser.photoURL
        }
        set {
            // Change storage
            let changeRequest = firUser.profileChangeRequest()
            changeRequest.photoURL = newValue
            changeRequest.commitChanges(){ (error) in
                if let error = error {
                    print("Error updating User photo url: \(error.localizedDescription)")
                }
            }
            // Change database
            let data = [UserProfile.Key.avatarURL: newValue?.absoluteString as AnyObject]
            userProfileReference?.updateChildValues(data)
        }
    }
    
    // MARK: - Methods

    required init(_ user: FIRUser) {
        firUser = user
        super.init()
    }
    
    // MARK: - Class methods
    
    /**
     Creates a new user using stock FIRUser and creates a new UserProfile to Database
     */
    public class func createUser(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        // Create stock FIRUser
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (newFIRUser: FIRUser?, error: Error?) in
            if let error = error {
                print("Error creating new user: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            else if let newFIRUser = newFIRUser {
                let user = UserAccount(newFIRUser)
                // Create UserProfile (overwrite any existing leaf data)
                let username = newFIRUser.email!.components(separatedBy: "@")[0]
                let data = [UserProfile.Key.timestamp: Date().description as AnyObject,
                            UserProfile.Key.username: username as AnyObject]
                user.userProfileReference?.setValue(data, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        print("Error creating new user on Database: \(error.localizedDescription)")
                    }
                })
                
                // Set username to default email handle
                user.username = username
            
                AppState.shared.signedIn(AppState.shared.currentUser)

                completion?(newFIRUser, error)
            }
        })
    }
    
    // Return the user's meta data dictionary from Database using UID
    public class func profile(_ uid: String, completion:@escaping (UserProfile)->()) {
        // Construct reference to user meta in Database
        let ref = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(uid)
        // Get existing values
        
        ref.observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            let userMeta = UserProfile(snapshot)
            completion(userMeta)
        })
    }
    
}

