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
    
    // For use with User.swift
//    var currentUser: User? {
//        get {
//            return User(firebaseAuth?.currentUser)
//        }
//    }
    var currentUser: FIRUser? {
        get {
            return firebaseAuth?.currentUser
        }
    }
    var firebaseAuth: FIRAuth? {
        get {
            return FIRAuth.auth()
        }
    }
    var userProfileChangeRequest: FIRUserProfileChangeRequest? {
        get {
            return currentUser?.profileChangeRequest()
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
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
                
        // Broadcast signin notification (AppDelegate should pick up and present Root VC
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.didSignIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        print("Login successful")
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

