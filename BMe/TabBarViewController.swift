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


        setupButtons()
        
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])

    }
    
    // Set icon in Tab bar
    func setupButtons() {
        // Browse button
        tabs[0].titleLabel?.font = UIFont.fontAwesome(ofSize: 55)
        tabs[0].setTitle(String.fontAwesomeIcon(name: .home), for: .normal)
        
        // Create button
        tabs[1].layer.cornerRadius = 0.5 * createButton.bounds.size.width
        // createButton.layer.borderWidth = 2.0
        tabs[1].clipsToBounds = true
        tabs[1].titleLabel?.font = UIFont.fontAwesome(ofSize: 50)
        tabs[1].setTitle(String.fontAwesomeIcon(name: .plus), for: .normal)
        
        // Account button
        tabs[2].titleLabel?.font = UIFont.fontAwesome(ofSize: 50)
        tabs[2].setTitle(String.fontAwesomeIcon(name: .user), for: .normal)

        
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
