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

// Made to complement FIRUser with extra metadata stored on database (FIRUser is not directly editable)
class User: NSObject {
    
    // General reference
    private var firUserDBReference: FIRDatabaseReference? {
        get {
            // Path: Database/<User Meta key>/<UID>/
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
            // Change storage
            let changeRequest = firUser.profileChangeRequest()
            changeRequest.displayName = newValue
            changeRequest.commitChanges(){ (error) in
                if let error = error {
                    print("Error updating User display name: \(error.localizedDescription)")
                }
            }
            // Change database
            let data = [UserMeta.Key.username: newValue as AnyObject]
            firUserDBReference?.updateChildValues(data) 
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
            let data = [UserMeta.Key.avatarURL: newValue?.absoluteString as AnyObject]
            firUserDBReference?.updateChildValues(data)
        }
    }
    
    // MARK: - methods

    required init(_ user: FIRUser) {
        firUser = user
        super.init()
    }
    
    // MARK: - Class methods
    
    // Creates a new user using stock FIRUser and adds a corresponding user object onto Database to hold extraneous information (metadata) not held by FIRUser
    public class func createUser(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (newFIRUser: FIRUser?, error: Error?) in
            if let error = error {
                print("Error creating new user: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            else if let newFIRUser = newFIRUser {
                // Create DB userMeta obj using defaults (overwrite any existing leaf data)
                let user = User(newFIRUser)
                let username = newFIRUser.email!.components(separatedBy: "@")[0]
                let data = [UserMeta.Key.createdAt: Date().description as AnyObject,
                            UserMeta.Key.username: username as AnyObject]
                user.firUserDBReference?.setValue(data, withCompletionBlock: { (error, ref) in
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
    public class func userMeta(_ uid: String, block:@escaping (UserMeta)->()) {
        // Construct reference to user meta in Database
        let ref = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(uid)
        // Get existing values
        ref.observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            let data = snapshot.dictionary
            let userMeta = UserMeta(data)
            block(userMeta)
        })
    }
    
}

