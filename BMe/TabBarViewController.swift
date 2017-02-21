//
//  TabBarViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import QuartzCore

enum Tab: Int {
    case Browse = 0
    case Camera
    case Account
}

class TabBarViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabs: [UIButton]!
    // scroll title text

    // MARK: Properties
    /** Child view controller of browse page view controller */
    private var browseViewController: UIViewController!
    /** Child view controller of camera page view controller. */
    private var cameraViewController: CameraViewController_old!
    /** Child view controller of camera page view controller. */
    private var createViewController: UINavigationController!
    private var accountViewController: UIViewController!
    private var viewControllers: [UIViewController]!
    
    /** Selected index of tab bar. Initial index is defined in Constants.swift. */
    private var selectedIndex: Int = Constants.TabBar.selectedIndex  // tag value from selected UIButton

    /** original tab position to show tabbar with animation */
    fileprivate var tabOriginalCenterYPositions: [CGFloat] = [CGFloat]()
    
    // To layout each tab button at appropriate position
    /** Width of each "box" by dividing view by 3 */
    private var oneThirdOfViewWidth: CGFloat { return view.frame.width / CGFloat(tabs.count) }
    /** Center x coordinate inside the area where view width is divided by three */
    private var centerOffset: CGFloat { return oneThirdOfViewWidth / 2 }   // Get the center offset in box
    
    /** to detect if it is just after app started. if so, don't enable camera button to take picture. */
    private var isInitialStartup: Bool = true
    /** labels that show title of page at the top. */
    fileprivate var titleLabels: [UILabel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()

        setupTabs()
        layoutTabs()
        
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])
        isInitialStartup = false
        
    }
    
    // MARK: View Controller Initial Setup
    
    private func setupViewControllers() {
        // Initialize and setup tabbar viewcontrollers
        // Browse view controller
        browseViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Home, bundle: nil).instantiateInitialViewController()
        addChildViewController(browseViewController)
        
        // Camera view controller which will be in camera page view controller
        cameraViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Camera, bundle: nil).instantiateInitialViewController() as? CameraViewController_old
        cameraViewController.delegate = self
        addChildViewController(cameraViewController)
        
        // Account view controller
      accountViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()
      addChildViewController(accountViewController)
        
        // Init with view controllers
        viewControllers = [browseViewController, cameraViewController, accountViewController]
    }
    
    
    // MARK: Tab Setups
    /** Sets icon image of all the tabs using setupTab(imageName:tabIndex) */
    private func setupTabs() {
        setupTab(imageName: Constants.Images.home, tabIndex: Tab.Browse.rawValue)
        setupTab(imageName: Constants.Images.circle, tabIndex: Tab.Camera.rawValue)
        setupTab(imageName: Constants.Images.user, tabIndex: Tab.Account.rawValue)
    }
    
    /** Sets icon image of tab at specified index */
    private func setupTab(imageName: String, tabIndex: Int) {
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
    
    /** Configures all tabs using layoutTab. Stores original y coordinate for the animation that shows and hides tabs. */
    private func layoutTabs () {
        layoutTab(index: Tab.Browse.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: Tab.Camera.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: Tab.Account.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        
        // Get original tab position to show tabbar with animation
        for tab in tabs {
            tabOriginalCenterYPositions.append(tab.center.y)
        }
    }
    
    /** Configures a tab with computed frame. */
    private func layoutTab(index: Int, w: CGFloat, h: CGFloat) {

        let y: CGFloat = view.frame.height - Constants.TabBar.unselectedTabSize
        var x: CGFloat = 0
        
        // Set only width and height
        tabs[index].frame = CGRect(x: CGRect.zero.origin.x, y: CGRect.zero.origin.y, width: w, height: h)
        
        // Get the center x coordinate
        if index == Tab.Browse.rawValue {
            x = centerOffset
        } else {
            x = centerOffset + oneThirdOfViewWidth * CGFloat(index)
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
        
        // Take picture when cameraButton tapped again in camera view (disabled in compose view)
        if previousIndex == Tab.Camera.rawValue && selectedIndex == Tab.Camera.rawValue && !isInitialStartup {
            cameraViewController.takePicture()
            
        } else {
            UIView.animate(withDuration: Constants.TabBar.tabbarAnimationDuration, animations: {
                // change the color
                self.tabs[previousIndex].imageView?.tintColor = Styles.Color.Secondary
                self.tabs[self.selectedIndex].imageView?.tintColor = Styles.Color.Primary
                
                // Reset image
                // Set unselected to white
                var whiteButton: UIImage? = UIImage()
                switch previousIndex {
                    case Tab.Browse.rawValue:
                        whiteButton = UIImage(named: Constants.Images.home)
                    case Tab.Camera.rawValue:
                        whiteButton = UIImage(named: Constants.Images.circle)
                    case Tab.Account.rawValue:
                        whiteButton = UIImage(named: Constants.Images.user)
                    default:
                        break
                }
                self.tabs[previousIndex].setImage(whiteButton, for: .normal)
                
                // Set selected to yellow
                var yellowButton: UIImage? = UIImage()
                switch self.selectedIndex {
                    case Tab.Browse.rawValue:
                        yellowButton = UIImage(named: Constants.Images.homeYellow)
                    case Tab.Camera.rawValue:
                        yellowButton = UIImage(named: Constants.Images.circleYellow)
                    case Tab.Account.rawValue:
                        yellowButton = UIImage(named: Constants.Images.userYellow)
                    default:
                        break
                }
                self.tabs[self.selectedIndex].setImage(yellowButton, for: .normal)
            
                
                self.layoutTab(index: previousIndex, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
                self.layoutTab(index: self.selectedIndex, w: Constants.TabBar.selectedTabSize, h: Constants.TabBar.selectedTabSize)
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
}

/** These methods are called by camera view controller to set the tab bar and title label state
 corresponding to the camera state.*/
extension TabBarViewController: CameraViewControllerDelegate_old {
    /** Show tab bar when camera mode is on. Called by camera view controller. */
    func showAllTabs() {
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions[i]
            }
        })
    }
    
    /** Hide tab bar when photo edit mode is on. Called by camera view controller. */
    func hideAllTabs() {
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions[i] + CGFloat(Constants.TabBar.selectedTabSize) + 20
            }
        })
    }
    
    /** Shows the left and right tabs. Called when bubble collection view is shown and filter button is down. */
    func showSideTabs() {
        let leftTabIndex = 0
        let rightTabIndex = tabs.count - 1
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            // very left tab
            self.tabs[leftTabIndex].center.y = self.tabOriginalCenterYPositions[leftTabIndex]
            // very right tab
            self.tabs[rightTabIndex].center.y = self.tabOriginalCenterYPositions[rightTabIndex]
        })
    }
    
    /** Hides the left and right tabs. Called when bubble collection view is hidden and filter button is up. */
    func hideSideTabs() {
        let leftTabIndex = 0
        let rightTabIndex = tabs.count - 1
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            // very left tab
            self.tabs[leftTabIndex].center.y = self.tabOriginalCenterYPositions[leftTabIndex] + CGFloat(Constants.TabBar.selectedTabSize) + 20
            // very right tab
            self.tabs[rightTabIndex].center.y = self.tabOriginalCenterYPositions[rightTabIndex] + CGFloat(Constants.TabBar.selectedTabSize) + 20
        })
    }
    
    /** Shows the center tab. Called when cancel button is tapped while bubble collection view is shown, filter button is down. */
    func showCenterTab() {
        let centerTabIndex: Int = tabs.count / 2
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration) { 
            self.tabs[centerTabIndex].center.y = self.tabOriginalCenterYPositions[centerTabIndex]
        }
        
    }
    
    /** Hides the center tab. Called nowhere but in case we need it. */
    func hideCenterTab() {
        let centerTabIndex: Int = tabs.count / 2
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration) {
            self.tabs[centerTabIndex].center.y = self.tabOriginalCenterYPositions[centerTabIndex] + CGFloat(Constants.TabBar.selectedTabSize) + 20
        }
    }
}
