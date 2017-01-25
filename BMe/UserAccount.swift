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
 UserAccount singleton tracks and updates currently logged in user's account.  Model is based on FIRUser and customized user data is implemented in UserProfile class
 */
class UserAccount: NSObject {
    
    // Implement singleton & hide initializer
    static let currentUser = UserAccount()
    private override init() {
        super.init()
    }
    
    // Model
    private var firUser: FIRUser? {
        get {
            return FIRAuth.auth()?.currentUser
        }
    }
    
    var isSignedIn: Bool {
        get {
            if firUser != nil {
                return true
            }
            return false
        }
    }
    
    var username: String? {
        get {
            return firUser?.displayName
        }
        set {
            if let firUser = firUser {
                // Change firUser display name
                let changeRequest = firUser.profileChangeRequest()
                changeRequest.displayName = newValue
                changeRequest.commitChanges(){ (error) in
                    if let error = error {
                        print("Error updating user display name: \(error.localizedDescription)")
                    }
                }
                // Change UserProfile
                let data = [UserProfile.Key.username: newValue as AnyObject]
                UserProfile.firebasePath(firUser.uid).updateChildValues(data)
            } else {
                print("Error cannot update username.  No user currently logged in")
            }
        }
    }
    
    var email: String? {
        get {
            return firUser?.email
        }
    }
    
    var avatarURL: URL? {
        get {
            // Returns the avatar's GS URL
            return firUser?.photoURL
        }
        set {
            // Change storage
            if let firUser = firUser {
                let changeRequest = firUser.profileChangeRequest()
                changeRequest.photoURL = newValue
                changeRequest.commitChanges(){ (error) in
                    if let error = error {
                        print("Error updating user photo url: \(error.localizedDescription)")
                    }
                }
                // Change UserProfile
                let data = [UserProfile.Key.avatarURL: newValue?.absoluteString as AnyObject]
                UserProfile.firebasePath(firUser.uid).updateChildValues(data)
            } else {
                print("Error cannot update avatar.  No user currently logged in")
            }
        }
    }
    
    var uid: String? {
        get {
            return firUser?.uid
        }
    }
    
    // MARK: - Methods
    
    func signIn(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if let error = error {
                print("Error on login: \(error.localizedDescription)")
                completion?(nil, error)
                return
            } else {
                self.signedIn()
                completion?(user, error)
            }
        })
    }
    
    func signedIn() {
        if UserAccount.currentUser.isSignedIn {
            MeasurementHelper.sendLoginEvent()
            
            // Broadcast signin notification (AppDelegate should pick up and present Root VC
            let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.didSignIn)
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
            print("Login successful")
        } else {
            print("Login failed- no user currently signed in")
        }
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            
            // Broadcast signout notification (AppDelegate should pick up and present Login VC
            let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.didSignOut)
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
            
            print("Signed out successfully")
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    //TODO: - Hook this up
    /*
     func didRequestPasswordReset() {
     let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
     let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
     let userInput = prompt.textFields![0].text
     if (userInput!.isEmpty) {
     return
     }
     AppState.shared.firebaseAuth?.sendPasswordReset(withEmail: userInput!) { (error) in
     if let error = error {
     print(error.localizedDescription)
     return
     }
     }
     }
     prompt.addTextField(configurationHandler: nil)
     prompt.addAction(okAction)
     present(prompt, animated: true, completion: nil);
     }
     */

    // MARK: - Class methods
    
    /**
     Creates and switches to new user using stock FIRUser and creates a new UserProfile to Database.
     */
    public class func createUser(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        // Create stock FIRUser
        print("Attempting to create user")
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (newFIRUser: FIRUser?, error: Error?) in
            if let error = error {
                print("Error creating new user: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            else if let newFIRUser = newFIRUser {
                print("Created new user with uid \(newFIRUser.uid)")
                
                // TODO: let users choose a unique username
                let username = newFIRUser.email!.components(separatedBy: "@")[0]
                // Set username to default email handle
                UserAccount.currentUser.username = username
                
                // Create UserProfile (overwrite any existing leaf data)
                let data = [UserProfile.Key.timestamp: Date().description as AnyObject,
                            UserProfile.Key.username: username as AnyObject]
                UserProfile.firebasePath(newFIRUser.uid).updateChildValues(data)
                
                // Complete sign in
                UserAccount.currentUser.signedIn()
                completion?(newFIRUser, error)
            }
        })
    }
}

