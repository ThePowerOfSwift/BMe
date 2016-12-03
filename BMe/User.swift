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
    
    // Model
    private var firUser: FIRUser
    
    private var firUserDBReference: FIRDatabaseReference? {
        get {
            return FIRManager.shared.database.child(FIRManager.ObjectKey.userMeta).child(firUser.uid)
        }
    }
    var uid: String? {
        get {
            return firUser.uid
        }
    }
    var username: String? {
        get {
            return firUser.displayName
        }
        set {
            let changeRequest = firUser.profileChangeRequest()
            changeRequest.displayName = newValue
            changeRequest.commitChanges(){ (error) in
                if let error = error {
                    print("Error updating User display name: \(error.localizedDescription)")
                }
            }
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
            let data = [Key.avatarURL: newValue?.absoluteString as AnyObject]
            firUserDBReference?.updateChildValues(data)
        }
    }
    
    //MARK: - Structs
    struct Key {
        static let createdAt = "createdAt"
        static let avatarURL = "avatarURL"
    }
    
    struct Data {
        
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
                let data = [Key.createdAt: Date().description as AnyObject]
                user.firUserDBReference?.setValue(data, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        print("Error creating new user on Database: \(error.localizedDescription)")
                    }
                })
                
                // Set username to default email handle
                user.username = newFIRUser.email!.components(separatedBy: "@")[0]
            
                AppState.shared.signedIn(AppState.shared.currentUser)

                completion?(newFIRUser, error)
            }
        })
    }
}

// Retrieves the user meta object from the Database
class UserMeta: NSObject {
    var uid: String
    
    var avatarURL: URL?
    var createdAt: Date?
    
    required init(_ uid: String, completion:((UserMeta?)->())?) {
        self.uid = uid
        super.init()
        
        // Get reference to user metadata on Database & check it exists
        let ref = FIRManager.shared.database.child(FIRManager.ObjectKey.userMeta).child(uid)
        ref.exists { (exists) in
            // Get object data
            if exists {
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let data = snapshot.value as! [String: AnyObject?]

                    if let avatar = data[User.Key.avatarURL] as? String {
                        self.avatarURL = URL(string: avatar)
                    }
                    if let created = data[User.Key.createdAt] as? String {
                        self.createdAt = created.toDate()
                    }
                    
                    completion?(self)
                })
            }
            else { completion?(nil) }
        }
    }
}
