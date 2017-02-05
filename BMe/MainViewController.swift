//
//  MainViewController.swift
//  BMe
//
//  Created by Lu Ao on 1/28/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var aboutPageView: UIScrollView!
    @IBOutlet weak var pagingControl: UIPageControl!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aboutPageView.frame = CGRect(x:16, y:28, width:343, height:351)
        let aboutPageViewWidth:CGFloat = self.aboutPageView.frame.width
        let aboutPageViewHeight:CGFloat = self.aboutPageView.frame.height
        
        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:aboutPageViewWidth, height:aboutPageViewHeight))
        imgOne.image = #imageLiteral(resourceName: "hook-black.png")
        let imgTwo = UIImageView(frame: CGRect(x:aboutPageViewWidth + 1, y:0,width:aboutPageViewWidth, height:aboutPageViewHeight))
        imgTwo.image = #imageLiteral(resourceName: "home")
        let imgThree = UIImageView(frame: CGRect(x:2*aboutPageViewWidth, y:0,width:aboutPageViewWidth, height:aboutPageViewHeight))
        imgThree.image = #imageLiteral(resourceName: "hook-blue.png")
        
        self.aboutPageView.addSubview(imgOne)
        self.aboutPageView.addSubview(imgTwo)
        self.aboutPageView.addSubview(imgThree)
        
        self.aboutPageView.contentSize = CGSize(width:self.aboutPageView.frame.width * 4, height:self.aboutPageView.frame.height)
        self.aboutPageView.delegate = self
        self.pagingControl.currentPage = 0
        
        // Do any additional setup after loading the view.
        // Add notification send user back to login screen after logout
        NotificationCenter.default.addObserver(self, selector: #selector(presentRootVC), name: NSNotification.Name(rawValue: Constants.NotificationKeys.didSignIn), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserAccount.currentUser.isSignedIn {
            UserAccount.currentUser.signedIn()
        }
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
    
    func presentRootVC() {
        self.present(self.getRootVCForUserLoggedIn(), animated: false, completion: nil)
    }
    
    /*
     Get ViewController for existed signedIn
    **/
    func getRootVCForUserLoggedIn() -> UIViewController {
        let storyboard = UIStoryboard.init(name: Constants.OnLogin.StoryboardID, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: Constants.OnLogin.RootViewController)
        return rootVC
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
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pagingControl.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0{
            
        }else if Int(currentPage) == 1{
            
        }else if Int(currentPage) == 2{
            
        }else{
            
        }
    }

}
