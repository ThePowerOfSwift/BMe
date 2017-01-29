//
//  MainViewController.swift
//  BMe
//
//  Created by Lu Ao on 1/28/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        self.present(self.getRootVCForLogin(), animated: false, completion: nil)
    }

    @IBAction func didTapSignUp(_ sender: Any) {
        self.present(getRootVCForSignUp(), animated: false, completion: nil)
    }
    
    
    func getRootVCForLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.ToLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.ToLogin.RootViewController)
        return rootVC
    }

    
    /**
     Get the SignUpViewController
     - Returns: UIViewController
     */
    func getRootVCForSignUp() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: Constants.OnSignUp.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnSignUp.RootViewController)
        return rootVC
    }
    
}
