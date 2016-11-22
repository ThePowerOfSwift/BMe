//
//  LoginViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

// MARK: - Outlets methods

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
// MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            signedIn(user)
        }
    }

// MARK: - Action methods
    
    @IBAction func didTapLogin(_ sender: AnyObject) {
        
        // check login inputs
        guard let email = usernameTextField.text,
            let password = passwordTextField.text
            else { return }
        
        // Sign In with credentials.
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error on login: \(error.localizedDescription)")
                return
            }
            self.signedIn(user!)
        }
    }
    
    @IBAction func didTapSignUp(_ sender: AnyObject) {
        guard let email = usernameTextField.text, let password = passwordTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.setDisplayName(user!)
        }
    }

    
    //TODO: - Ask user for a handle instead of taking email root
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    //TODO: - Hook this up
    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
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
    
    // MARK: -  Methods
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        // Update user info
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        AppState.sharedInstance.userID = user?.uid
        
        // Broadcast signin notification (AppDelegate should pick up and present Root VC
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.didSignIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        
        // Present root vc after login success
        present(getRootVCAfterLogin(), animated: true, completion: nil)
    }

    func signOut(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            // TODO: - redirect to VC
            
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func getRootVCAfterLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        return rootVC
    }
}

