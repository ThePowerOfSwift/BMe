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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        setupButtons()
        
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
        loginButton.isEnabled = false
        self.present(self.getRootVCForLogin(), animated: false, completion: nil)
    }

    @IBAction func didTapSignUp(_ sender: Any) {
        signupButton.isEnabled = false
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
    
    
    //ScrollView Delegate, to calculate which page is showing, can be use if needed
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
        // Change the dot indicator
        self.pagingControl.currentPage = Int(currentPage)
    }
    
    /**
     Setup the scroll view, it's conttent and margin and more
    */
    func setUpScrollView(){
        //Setup the szie for scroll view to be the same size of the screen
        self.aboutPageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let aboutPageViewWidth:CGFloat = self.aboutPageView.frame.width
        let aboutPageViewHeight:CGFloat = self.aboutPageView.frame.height
        
        // It is UIImageView now, can be replaced by .xib, if need, but not yet be tested suceessfully
        let imgOne = UIImageView(frame: CGRect(x: 0, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        imgOne.contentMode = .scaleAspectFit
        imgOne.image = nil
        
        let imgTwo = UIImageView(frame: CGRect(x: aboutPageViewWidth, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        imgTwo.contentMode = .scaleAspectFit
        imgTwo.image = nil
        
        let imgThree = UIImageView(frame: CGRect(x: aboutPageViewWidth * 2, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        imgThree.contentMode = .scaleAspectFit
        imgThree.image = nil
        
        let imgFour = UIImageView(frame: CGRect(x: aboutPageViewWidth * 3, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        imgFour.contentMode = .scaleAspectFit
        imgFour.image = nil
        
        let imgFive = UIImageView(frame: CGRect(x: aboutPageViewWidth * 4, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        imgFive.contentMode = .scaleAspectFit
        imgFive.image = nil
        
        let testView = BusyView(frame: CGRect(x: aboutPageViewWidth * 5, y: 0,width: aboutPageViewWidth, height: aboutPageViewHeight))
        
        // Add views in order in the scroll view
        self.aboutPageView.addSubview(imgOne)
        self.aboutPageView.addSubview(imgTwo)
        self.aboutPageView.addSubview(imgThree)
        self.aboutPageView.addSubview(imgFour)
        self.aboutPageView.addSubview(imgFive)
        self.aboutPageView.addSubview(testView)
        
        // Setup total numbers of pages and total numbers of dots
        self.aboutPageView.contentSize = CGSize(width :self.aboutPageView.frame.width * 6, height: self.aboutPageView.frame.height)
        self.aboutPageView.delegate = self
        self.pagingControl.currentPage = 0
        self.pagingControl.numberOfPages = 6
        
    }
    
    func setupButtons() -> Void{
        loginButton.isEnabled = true
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.blue.cgColor
        signupButton.isEnabled = true
        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.blue.cgColor
        
    }
    

}
