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
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewWidthConstraint: NSLayoutConstraint!
    
// MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = Styles.Color.Primary
        logoImageViewWidthConstraint.constant = Styles.Logo.size.width
        logoImageViewHeightConstraint.constant = Styles.Logo.size.height
        logoImageView.image = UIImage(named: Constants.Images.hookBlack)
            
        // Subscribe to notifications for login (and send to root VC)
        // Add notification send user back to login screen after logout
        NotificationCenter.default.addObserver(self, selector: #selector(presentRootVC), name: NSNotification.Name(rawValue: Constants.NotificationKeys.didSignIn), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = AppState.shared.currentUser {
            AppState.shared.signedIn(user)
        }
    }

// MARK: - Action methods
    
    @IBAction func didTapLogin(_ sender: AnyObject) {
        
        // check login inputs
        guard let email = usernameTextField.text,
            let password = passwordTextField.text
            else { return }
        
        // Sign In with credentials.
        AppState.shared.signIn(withEmail: email, password: password) { (user: FIRUser?, error: Error?) in
            // Present error alert
            self.presentErrorAlert(error: error)
        }
        
    }
    
    @IBAction func didTapSignUp(_ sender: AnyObject) {
        guard let email = usernameTextField.text,
            let password = passwordTextField.text
            else { return }
        
        // Sign up with credentials
        User.createUser(withEmail: email, password: password) { (user: FIRUser?, error: Error?) in
            // Present error alert
            self.presentErrorAlert(error: error)
        }

    }
    
    // MARK: -  Methods
    let intervals: TimeInterval = 0.5
    func animateSignIn() {
        UIView.animate(withDuration: intervals, animations: {
            // disappear logo
            self.logoImageView.alpha = 0
        }, completion: { (success) in
            self.logoImageView.image = UIImage(named: Constants.Images.hookYellow)
            UIView.animate(withDuration: self.intervals , animations: {
                self.logoImageView.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: self.intervals, animations: {
                    self.logoImageView.alpha = 0
                })
                // Present root vc after login success
                self.present(self.getRootVCAfterLogin(), animated: false, completion: nil)
            })
        })
    }
    
    func presentRootVC() {
        animateSignIn()
    }

    func getRootVCAfterLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        return rootVC
    }
    
    func presentErrorAlert(error: Error?) {
        // Present error alert
        if let error = error {
            let prompt = UIAlertController.init(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            prompt.addAction(okAction)
            
            present(prompt, animated: true, completion: nil)
        }
    }
}

