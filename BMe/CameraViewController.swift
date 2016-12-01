//
//  CameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!

    @IBAction func tappedAddTextButton(_ sender: Any) {
        addTextFieldToView()
    }
    
    //MARK:- Model
    var textFields: [UITextField] = []
    
    //MARK:- Variables
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Methods
    
    func addTextFieldToView() {
        let textField = UITextField()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedTextField(_:)))
        textField.addGestureRecognizer(tap)
        
        
        textFields.append(textField)
    }
    
    func tappedTextField(_ sender: UITapGestureRecognizer) {
        let textField = sender.view
        textField?.removeFromSuperview()
    }
    
    func getTextFieldInView() -> [UITextField] {
        var textFields: [UITextField] = []
        for view in cameraControlView.subviews {
            if isKind(of: UITextField.self) {
                let textfield = view
                textFields.append(textfield as! UITextField)
            }
        }
        return textFields
    }
    
}
