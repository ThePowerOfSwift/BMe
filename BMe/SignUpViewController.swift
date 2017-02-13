//
//  SignUpViewController.swift
//  BMe
//
//  Created by Lu Ao on 1/25/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var onContinueButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var username: String?
    var email: String?
    var password: String?
    var state: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passWordTextField.delegate = self
        if state == "username"{
            toEnterUsernameState()
        }
        else{
            toEnterEmail()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        userNameTextField.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        userNameTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if state == "username"{
            //TODO: Check against username format once there is one
            if userNameTextField.text == ""{
                presentEmptyFieldErrorAlert()
            }
            else{
                performSegue(withIdentifier: "FillEmail", sender: nil)
            }
            return true
        }
        else{
            if textField == userNameTextField{
                userNameTextField.resignFirstResponder()
                passWordTextField.becomeFirstResponder()
            }
            else{
                if let email = userNameTextField.text, let password = passWordTextField.text, let username = self.username{
                    UserAccount.createUser(withUsername: username, email: email, password: password) { (user: FIRUser?, error: Error?) in
                        // Present error alert
                        self.presentErrorAlert(error: error)
                        if user != nil{
                            self.presentRootVC()
                        }
                    }
                }
                else {
                    presentEmptyFieldErrorAlert()
                    
                }
            }
        }
        return true
    }
    
    /**
    Pressing button will either continue filling out email address or submit everything
    */
    @IBAction func onContinue(_ sender: Any) {
        if state == "username"{
            //TODO: Check against username format once there is one
            if userNameTextField.text == ""{
                presentEmptyFieldErrorAlert()
            }
        }
        else{
            guard let email = userNameTextField.text,
                let password = passWordTextField.text,
                let username = self.username
                else {
                    presentEmptyFieldErrorAlert()
                    return
            }
            
            // Sign up with credentials
            UserAccount.createUser(withUsername: username, email: email, password: password) { (user: FIRUser?, error: Error?) in
                // Present error alert
                print("test")
                self.presentErrorAlert(error: error)
                if user != nil{
                    self.presentRootVC()
                }
            }
        }
    }
    
    @IBAction func onEditing(_ sender: Any) {
        if state == "username"{
            self.username = self.userNameTextField.text! //Save previous
        }
        else{
            self.email = self.userNameTextField.text!
        }
    }
    
    func presentRootVC() {
        self.present(self.getRootVCAfterLogin(), animated: false, completion: nil)
    }
    
    func getRootVCAfterLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        return rootVC
    }
    
    
    
    /**
     Change appearence for textfield and button when entering username
     - Hide the password textfield
     - Username textfield placeholder should be "username"
     - Title on the button should be "Continue"
    */
    func toEnterUsernameState() -> Void{
        if let username = self.username{
            userNameTextField.text = username
        }
        else{
            userNameTextField.text = ""
        }
        self.onContinueButton.setTitle("Continue", for: .normal)
        self.passWordTextField.isHidden = true
        self.userNameTextField.placeholder = "username"
        self.onContinueButton.setTitle("Continue", for: .normal)
        self.descriptionLabel.text = "Please enter a your username"
    }
    /**
     Change appearence for textfield and button when entering username
     - Unhide the password textfield
     - Password textfield placeholder should be "password"
     - Username textfield placeholder should be "email"
     - Title on the button should be "Submit"
     */
    func toEnterEmail() -> Void{//-> UIViewController{
        if let email = self.email{
            userNameTextField.text = email
        }
        else{
            userNameTextField.text = ""
        }
        passWordTextField.isHidden = false
        passWordTextField.placeholder = "password"
        userNameTextField.placeholder = "email"
        userNameTextField.becomeFirstResponder()
        onContinueButton.setTitle("Submit", for: .normal)
        descriptionLabel.text = "Please enter email address and password for login."
        //return rootVC
    }
    
    /**
     Present Error Alert
     
     - Parameter error: Nothing
     - Returns:  Void
     */
    func presentErrorAlert(error: Error?) {
        // Present error alert
        if let error = error {
            let prompt = UIAlertController.init(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            prompt.addAction(okAction)
            
            present(prompt, animated: true, completion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil) // Send user back to login page and automatically login after sign up
        }
    }
    /**
     Present empty fields alert
    */
    func presentEmptyFieldErrorAlert() -> Void {
        // Present error alert
        let prompt = UIAlertController.init(title: "Error", message: "Please fill out all fields.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SignUpViewController
        vc.state = "email"
        vc.username = self.userNameTextField.text
    }
    

}
