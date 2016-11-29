//
//  MetaViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol MetaViewControllerDelegate: class {
    func post(meta: [String: String])
}

class MetaViewController: UIViewController, UITextFieldDelegate {

    struct Key {
        static let name = "name"
        static let restaurant = "restaurant"
    }
    
    // MARK: - Outlets
    @IBOutlet weak var restaurantTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var delegate: MetaViewControllerDelegate?
    
    // MARK: - Lifecycle:- Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        restaurantTextField.delegate = self
        nameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    @IBAction func postTapped(_ sender: UIButton) {
        let meta: [String: String] = [Key.name: nameTextField.text!,
                    Key.restaurant: restaurantTextField.text!]
        delegate?.post(meta: meta)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TextField Delegate methods
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
