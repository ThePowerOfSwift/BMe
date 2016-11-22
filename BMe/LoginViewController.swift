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
        // Subscribe to notifications for login (and send to root VC)
        // Add notification send user back to login screen after logout
        NotificationCenter.default.addObserver(self, selector: #selector(presentRootVC), name: NSNotification.Name(rawValue: Constants.NotificationKeys.didSignIn), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = AppState.sharedInstance.currentUser {
            AppState.sharedInstance.signedIn(user)
        }
    }

// MARK: - Action methods
    
    @IBAction func didTapLogin(_ sender: AnyObject) {
        
        // check login inputs
        guard let email = usernameTextField.text,
            let password = passwordTextField.text
            else { return }
        
        // Sign In with credentials.
        AppState.sharedInstance.signIn(withEmail: email, password: password) { (user: FIRUser?, error: Error?) in
            if let error = error {
                print("Error on login: \(error.localizedDescription)")
                return
            }
        }
    }
    
    @IBAction func didTapSignUp(_ sender: AnyObject) {
        guard let email = usernameTextField.text, let password = passwordTextField.text else { return }
        AppState.sharedInstance.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
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
            AppState.sharedInstance.firebaseAuth?.sendPasswordReset(withEmail: userInput!) { (error) in
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
    
    //TODO: - Hook this up
    @IBAction func signOut(_ sender: UIButton) {
        AppState.sharedInstance.signOut()
    }
    
    
    // MARK: -  Methods
    
    func presentRootVC() {
        // Present root vc after login success
        present(getRootVCAfterLogin(), animated: true, completion: nil)
    }

    func getRootVCAfterLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        return rootVC
    }
}

