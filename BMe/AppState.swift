//
//  AppState.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import Foundation
import Firebase

class AppState: NSObject {
    
    static let shared = AppState()
    
    // Hide singleton initializer
    private override init() {
        super.init()
    }
    
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
    var userID: String?
    
    var currentUser: FIRUser? {
        get {
            return FIRAuth.auth()?.currentUser
        }
    }
    var firebaseAuth: FIRAuth? {
        get {
            return FIRAuth.auth()
        }
    }
    
// MARK: - Methods
    func signIn(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        firebaseAuth?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if let error = error {
                print("Error on login: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            else {
                self.signedIn(user)
                completion?(user, error)
            }
        })

    }
    
    func createUser(withEmail email: String, password: String, completion: FirebaseAuth.FIRAuthResultCallback? = nil) {
        firebaseAuth?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if let error = error {
                print("Error creating new user: \(error.localizedDescription)")
                completion?(nil, error)
                return
            }
            else {
                self.setUserDisplayName(user!)
                completion?(user, error)
            }
        })
    }
    
    // TODO: - have user input user handle
    func setUserDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print("Error updating user info: \(error.localizedDescription)")
                return
            }

            self.signedIn(AppState.shared.currentUser)
        }
    }
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        // Populate singleton properties
        updateUser(user)
        
        // Broadcast signin notification (AppDelegate should pick up and present Root VC
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.didSignIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        print("Login successful")
    }
    
    func updateUser(_ user: FIRUser?) {
        // Update user info
        displayName = user?.displayName ?? user?.email
        photoURL = user?.photoURL
        signedIn = true
        userID = user?.uid
    }
    
    func signOut() {
        do {
            try firebaseAuth?.signOut()
            signedIn = false

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
}
