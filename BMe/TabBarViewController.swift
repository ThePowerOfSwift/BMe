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
    var cameraNavigationController: UINavigationController!
    var createViewController: UIViewController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
    // tag value from selected UIButton
    var selectedIndex: Int = 0
    
    // tab size
    var selectedTabSize: Double = 70
    var unselectedTabSize: Double = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()

        browseViewController = UIStoryboard(name: "Browser", bundle: nil).instantiateInitialViewController()

        let createStoryboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        createViewController = createStoryboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.mediaSelectorNavigationController)

        cameraNavigationController = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let cameraViewController = cameraNavigationController.viewControllers[0] as! CameraViewController
        cameraViewController.cameraButton = tabs[1] //not passing the copy but reference
        
        
        accountViewController = UIStoryboard(name: "Account", bundle: nil).instantiateInitialViewController()
        
        // Init with view controllers
        viewControllers = [browseViewController, cameraViewController, createViewController, accountViewController]

        setupTabs()
        layoutTabs()
        
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])
        
        for i in 0...tabs.count-1 {
            if tabs[i].isSelected {
                tabs[i].imageView?.tintColor = Styles.Color.Primary
            } else {
                tabs[i].imageView?.tintColor = Styles.Color.Secondary
            }
        }

    }
    
    // MARK: Tab Setups
    
    // Call setupButtons(imageName, tabIndex) to setup tabs
    func setupTabs() {
        setupTab(imageName: "home", tabIndex: 0)
        setupTab(imageName: Constants.Images.circle, tabIndex: 1)
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
            button.imageView?.tintColor = Styles.Color.Primary
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
    
    // MARK: Tab Action
    
    @IBAction func didTapTab(_ sender: UIButton) {
        // Previous view controller
        let previousIndex = selectedIndex
        selectedIndex = sender.tag // Assign the index of current tab to selectedIndex
        tabs[selectedIndex].isSelected =  true
        UIView.animate(withDuration: 0.1, animations: {
            // change the color
            self.tabs[previousIndex].imageView?.tintColor = Styles.Color.Secondary
            self.tabs[self.selectedIndex].imageView?.tintColor = Styles.Color.Primary
            
            // Reset image
            
            switch previousIndex {
//                case 0:
                    //self.tabs[previousIndex].imageView?.image = UIImage(named: Constants.Images.)
                case 1:
                    let whiteButton = UIImage(named: Constants.Images.circle)
                    self.tabs[previousIndex].setImage(whiteButton, for: .normal)
//                case 2:
//                case 3:
                default:
                    print("default swifth statemetn in didTapTab")
            }
        
            
            switch self.selectedIndex {
//                case 0:
                case 1:
                    let yellowButton = UIImage(named: Constants.Images.circleYellow)
                    self.tabs[self.selectedIndex].setImage(yellowButton, for: .normal)
//                case 2:
//                case 3:
                default:
                    print("default swifth statemetn in didTapTab")
            }
            
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
