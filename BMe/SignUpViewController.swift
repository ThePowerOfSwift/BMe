//
//  SignUpViewController.swift
//  BMe
//
//  Created by Lu Ao on 1/25/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var onContinueButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var username: String?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toEnterUsername()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Pressing back will either go back to login page(cancel) or re-enter username
    */
    @IBAction func onBack(_ sender: Any) {
        if infoEnterState() == "username"{
            self.dismiss(animated: true, completion: nil)
        }
        else{
            toEnterUsername()
        }
    }
    
    /**
    Pressing button will either continue filling out email address or submit everything
    */
    @IBAction func onContinue(_ sender: Any) {
        if infoEnterState() == "username"{
            toEnterEmail()
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
                self.presentErrorAlert(error: error)
            }
        }
    }
    
    @IBAction func onEditing(_ sender: Any) {
        if infoEnterState() == "username"{
            self.username = self.userNameTextField.text! //Save previous
        }
        else{
            self.email = self.userNameTextField.text!
        }
    }
    
    
    
    
    /**
     Change appearence for textfield and button when entering username
     - Hide the password textfield
     - Username textfield placeholder should be "username"
     - Title on the button should be "Continue"
    */
    func toEnterUsername() -> Void{
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
    func toEnterEmail() -> Void{
        if let email = self.email{
            userNameTextField.text = email
        }
        else{
            userNameTextField.text = ""
        }
        self.passWordTextField.isHidden = false
        self.passWordTextField.placeholder = "password"
        self.userNameTextField.placeholder = "email"
        self.onContinueButton.setTitle("Submit", for: .normal)
        self.descriptionLabel.text = "Please enter email address and password for login."
    }
    /**
    To increase readability
    */
    func infoEnterState() -> String{
        if self.onContinueButton.title(for: .normal) == "Continue"{
            return "username"
        }
        else{
            return "email"
        }
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
        let prompt = UIAlertController.init(title: "Error", message: "Please fill out all fields sucka!!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    

}
