//
//  TabBarViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class TabBarViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabs: [UIButton]!
    
    var browseViewController: UIViewController!
    var createViewController: UIViewController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
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

        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])
        
//        let button: UIButton = UIButton(type: .Custom)
//        let win:UIWindow = UIApplication.sharedApplication().delegate!.window!!
        
        
        createButton.frame = CGRect(x: 0.0, y: self.view.frame.size.height - 65, width: 55, height: 55)
        createButton.center = CGPoint(x:self.view.center.x , y: createButton.center.y)
        
//        button.setBackgroundImage(UIImage(named: "Camera") , forState: .Normal)
//        button.setBackgroundImage(UIImage(named: "Camera"), forState: .Highlighted)
//        win.addSubview(button)
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
