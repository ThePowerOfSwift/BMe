//
//  TabBarViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FontAwesome_swift
import QuartzCore

class TabBarViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabs: [UIButton]!
    
    var browseViewController: UIViewController!
    var createViewController: UIViewController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    // tag value from selected UIButton
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard.init(name: "Sato", bundle: nil)
        browseViewController = storyboard.instantiateViewController(withIdentifier: "BrowseNavigationController")

        let createStoryboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        createViewController = createStoryboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.mediaSelectorNavigationController)
        accountViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController")
        
        // Init with view controllers
        viewControllers = [browseViewController, createViewController, accountViewController]

        // Set icon in Tab bar
        //tabs[0].titleLabel?.text = String.fontAwesomeIcon(name: .github)
        tabs[0].titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        tabs[0].setTitle(String.fontAwesomeIcon(name: .anchor), for: .normal)
        //browseButton.titleLabel?.text = String.fontAwesomeIcon(name: .github)
        //browseButton.titleLabel?.text = "TITLTLTT"
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])

        
//        createButton.frame = CGRect(x: 0.0, y: self.view.frame.size.height - 65, width: 55, height: 55)
//        createButton.center = CGPoint(x:self.view.center.x , y: createButton.center.y)

        tabs[1].layer.cornerRadius = 0.5 * createButton.bounds.size.width
        //createButton.layer.borderColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1).cgColor as CGColor
        // createButton.layer.borderWidth = 2.0
        tabs[1].clipsToBounds = true
        tabs[1].titleLabel?.font = UIFont(name: "Helvetica", size: 50)
        tabs[1].setTitle("+", for: .normal)
//        //width and height should be same value
//        createButton.frame = CGRect(0, 0, ROUND_BUTTON_WIDTH_HEIGHT, ROUND_BUTTON_WIDTH_HEIGHT);
//        
//        //Clip/Clear the other pieces whichever outside the rounded corner
//        createButton.clipsToBounds = YES;
//        
//        //half of the width
//        createButton.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
//        createButton.layer.borderColor=[UIColor redColor].CGColor;
//        createButton.layer.borderWidth=2.0f;
    }
    
    @IBAction func didTapTab(_ sender: UIButton) {
        
        // Previous view controller
        let previousIndex = selectedIndex
        selectedIndex = sender.tag // Assign the index of current tab to selectedIndex
        tabs[previousIndex].isSelected = false
        let previousVC = viewControllers[previousIndex]
        // invoke view controller's life cycle and remove it from TabBarViewController
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        // New view controller
        sender.isSelected = true // Make current tab selected
        let currentVC = viewControllers[selectedIndex] // get vc at the selected index
        addChildViewController(currentVC) // calls viewWillAppear
        currentVC.view.frame = contentView.frame // set view size to content view size
        contentView.addSubview(currentVC.view)
        currentVC.didMove(toParentViewController: self) // calls viewDidAppear
        
    }
}
