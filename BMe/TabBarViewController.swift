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
    
    // tag value from selected UIButton
    var selectedIndex: Int = 0
    
    // tab size
    var selectedTabSize: Double = 50
    var unselectedTabSize: Double = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard.init(name: "Sato", bundle: nil)
        browseViewController = storyboard.instantiateViewController(withIdentifier: "BrowseNavigationController")

        let createStoryboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        createViewController = createStoryboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.mediaSelectorNavigationController)
        accountViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController")
        
        
        // Init with view controllers
        viewControllers = [browseViewController, createViewController, accountViewController]


        setupTabs()
        layoutTabs()
        
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])

    }
    
    // Call setupButtons(imageName, tabIndex) to setup tabs
    func setupTabs() {
        setupTab(imageName: "home", tabIndex: 0)
        setupTab(imageName: "double_circle", tabIndex: 1)
        setupTab(imageName: "food", tabIndex: 2)
        setupTab(imageName: "account", tabIndex: 3)
    }
    
    // Set icon image at index
    func setupTab(imageName: String, tabIndex: Int) {
        let image = UIImage(named: imageName)
        
        // Bound checking
        if tabIndex >= 0 && tabIndex < tabs.count {
            let button = tabs[tabIndex]
            button.setImage(image, for: .normal)
            button.imageView?.image? = (button.imageView?.image?.withRenderingMode(.alwaysTemplate))!
            button.imageView?.tintColor = UIColor(red: Styles.Color.primary.r, green: Styles.Color.primary.g, blue: Styles.Color.primary.b, alpha: 1)
        } else {
            print("index is not valid\n")
        }
    }
    
    func layoutTabs () {
        layoutTab(index: 0, w: unselectedTabSize, h: unselectedTabSize)
        layoutTab(index: 1, w: unselectedTabSize, h: unselectedTabSize)
        layoutTab(index: 2, w: unselectedTabSize, h: unselectedTabSize)
        layoutTab(index: 3, w: unselectedTabSize, h: unselectedTabSize)
    }
    
    func layoutTab(index: Int, w: Double, h: Double) {
        // Get the width of each "box" by dividing view by 4
        let boxWidth: Double = Double(view.frame.width) / 4
        // Get the center offset in box
        let centerOffset: Double = boxWidth / 2
        let y: Double = Double(view.frame.height) - unselectedTabSize
        var x: Double = 0
        
        // Set only width and height
        tabs[index].frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        // Get the center x coordinate
        if index == 0 {
            x = centerOffset
        } else {
            x = centerOffset + boxWidth * Double(index)
        }
        
        // Set center coordinate
        tabs[index].center = CGPoint(x: x, y: y)
    }
    
    @IBAction func didTapTab(_ sender: UIButton) {
        // Previous view controller
        let previousIndex = selectedIndex
        selectedIndex = sender.tag // Assign the index of current tab to selectedIndex
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutTab(index: previousIndex, w: self.unselectedTabSize, h: self.unselectedTabSize)
            self.layoutTab(index: self.selectedIndex, w: self.selectedTabSize, h: self.selectedTabSize)
        })
        
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
