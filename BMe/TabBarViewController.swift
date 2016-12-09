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

class TabBarViewController: UIViewController, UIScrollViewDelegate, PageViewDelegate, CameraViewDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabs: [UIButton]!
    
    var browseViewController: UIViewController!
    var browsePageViewController: PageViewController!
    
    var cameraNavigationController: UINavigationController!
    var cameraViewController: CameraViewController!
    var cameraPageViewController: PageViewController!
    var createViewController: UINavigationController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
    // tag value from selected UIButton
    var selectedIndex: Int = Constants.TabBar.selectedIndex
    
    // hide and show animation
    var tabOriginalCenterYPositions: [CGFloat]?
    
    // detect if it is just after app started. if so, don't enable camera button to take picture
    var isInitialStartup: Bool = true
    
    // scroll title text
    @IBOutlet weak var titleScrollView: UIScrollView!

    var titlePages: [UILabel] = [UILabel]()
    
    @IBOutlet weak var titleBar: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Browse view controller
        browseViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Browser, bundle: nil).instantiateInitialViewController()
        browsePageViewController = UIStoryboard(name: Constants.SegueID.Storyboard.PageView, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.PageViewController) as! PageViewController
        addChildViewController(browsePageViewController)
        
        let secondVC = UIStoryboard(name: Constants.SegueID.Storyboard.Featured, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.FeaturedViewController)
        browsePageViewController.orderedViewControllers = [browseViewController, secondVC]

        // Create view controller which will be in camera page view controller
        let createStoryboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        createViewController = createStoryboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.mediaSelectorNavigationController) as! UINavigationController
        
        // Preload media selector vc so paging in camera page vc will be smooth
        // Doing this here because it is hard to detect what view controller is showed  in page view controller (too many types of vcs in page view controller)
        let mediaSelectorVC = createViewController.viewControllers[0] as! MediaSelectorViewController
        _ = mediaSelectorVC.view

        // Camera view controller which will be in camera page view controller
        cameraNavigationController = UIStoryboard(name: Constants.SegueID.Storyboard.Camera, bundle: nil).instantiateInitialViewController() as! UINavigationController
        cameraViewController = cameraNavigationController.viewControllers[0] as! CameraViewController
        cameraViewController.cameraViewDelegate = self
        
        // Camera page view controller
        cameraPageViewController = UIStoryboard(name: Constants.SegueID.Storyboard.PageView, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.PageViewController) as! PageViewController
        cameraPageViewController.orderedViewControllers = [cameraViewController, createViewController]
        addChildViewController(cameraPageViewController)
        
        // Account view controller
        accountViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Account, bundle: nil).instantiateInitialViewController()
        addChildViewController(accountViewController)
        
        // Init with view controllers
        viewControllers = [browsePageViewController, cameraPageViewController, accountViewController]

        setupTabs()
        layoutTabs()
        obtainOriginalTabOriginalPositions()
        
        // Set first tab selected
        tabs[selectedIndex].isSelected = true
        didTapTab(tabs[selectedIndex])
        isInitialStartup = false
        
        // title text animateion
        browsePageViewController.pageViewDelegate = self
        cameraPageViewController.pageViewDelegate = self
        
        // scroll title 
        setupTitleScrollView()
    }
    
    // MARK: Scroll Title
    
    func setupTitleScrollView() {
        titleBar.backgroundColor = Styles.Color.Tertiary
        titleBar.alpha = 0
        // Round corner
        titleBar.layer.cornerRadius = 2
        titleBar.layer.masksToBounds = true
    }
    
    func changeTitleLabels(titles: [String]) {
        // Remove previous titls labels
        for view in titleScrollView.subviews {
            if let label = view as? UILabel {
                label.removeFromSuperview()
            }
        }
        
        titlePages = [UILabel]()
        for i in 0..<titles.count {
            var frame = CGRect()
            frame.origin.x = self.titleScrollView.frame.size.width * CGFloat(i)
            frame.size = self.titleScrollView.frame.size
            self.titleScrollView.isPagingEnabled = true
            let titleLabel = UILabel(frame: frame)
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 20)
            titleLabel.textColor = Styles.Color.Tertiary
            //titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.text = titles[i]
            titleScrollView.addSubview(titleLabel)
            titlePages.append(titleLabel)
        }
        
        titleScrollView.contentSize = CGSize(width: titleScrollView.frame.width * CGFloat(titles.count), height: titleScrollView.frame.size.height)
    }
    
    func scrollTitleTo(index: Int) {
        let point = CGPoint(x: titleScrollView.frame.width * CGFloat(index), y: 0)
        titleScrollView.setContentOffset(point, animated: true)
        
        for i in 0..<titlePages.count {
            if i == index {
                UIView.animate(withDuration: 0.5, animations: {
                    self.titlePages[i].alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.titlePages[i].alpha = 0.2
                })
            }
        }
        
        // animate bar

        UIView.animate(withDuration: 1, animations: {
            self.titleBar.alpha = 1
        }, completion: { (completed :Bool) in
            UIView.animate(withDuration: 1, animations: {
                self.titlePages[index].alpha = 0.2
                self.titleBar.alpha = 0
            })
        })
    }
    
    func setupAlphaAt(index: Int) {
        for i in 0..<titlePages.count {
            if i != index {
                UIView.animate(withDuration: 0.5, animations: {
                    self.titlePages[i].alpha = 0.2
                })
            }
        }
    }
    
    func showScrollTitle() {
        titleScrollView.isHidden = false
        titleBar.isHidden = false
    }
    
    func hideScrollTitle() {
        titleScrollView.isHidden = true
        titleBar.isHidden = true
    }
    
    // MARK: Tab Setups
    // Call setupButtons(imageName, tabIndex) to setup tabs
    func setupTabs() {
        setupTab(imageName: Constants.Images.home, tabIndex: 0)
        setupTab(imageName: Constants.Images.circle, tabIndex: 1)
        setupTab(imageName: Constants.Images.user, tabIndex: 2)
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
        layoutTab(index: 0, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: 1, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: 2, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
    }
    
    func layoutTab(index: Int, w: Double, h: Double) {
        // Get the width of each "box" by dividing view by 3
        let boxWidth: Double = Double(view.frame.width) / Double(tabs.count)
        // Get the center offset in box
        let centerOffset: Double = boxWidth / 2
        let y: Double = Double(view.frame.height) - Constants.TabBar.unselectedTabSize
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
    
    // Get dynamic tab original tab y coordinate for show and hide animation
    func obtainOriginalTabOriginalPositions() {
        tabOriginalCenterYPositions = [CGFloat]()
        for tab in tabs {
            tabOriginalCenterYPositions?.append(tab.center.y)
        }
    }
    
    // Show and hide tab bar
    func showTabBar() {
        UIView.animate(withDuration: 0.2, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions![i]
            }
        })
    }
    
    func hideTabBar() {
        UIView.animate(withDuration: 0.2, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions![i] + CGFloat(Constants.TabBar.selectedTabSize) + 20
            }
        })
    }
    
    // MARK: Tab Action
    @IBAction func didTapTab(_ sender: UIButton) {
        // Previous view controller
        let previousIndex = selectedIndex
        selectedIndex = sender.tag // Assign the index of current tab to selectedIndex
        tabs[selectedIndex].isSelected =  true
        
        // Show title scroll label if selected index is 1
        if selectedIndex != previousIndex || isInitialStartup {
            switch selectedIndex {
            case 0:
                changeTitleLabels(titles: Constants.PageTitles.browsePageTitles)
                showScrollTitle()
            case 1:
                changeTitleLabels(titles: Constants.PageTitles.cameraPageTitles)
                showScrollTitle()
            default:
                hideScrollTitle()
            }
        } 
        
        // Take picture when cameraButton tapped again in camera view (disabled in compose view)
        if previousIndex == 1 && selectedIndex == 1 && !isInitialStartup && cameraPageViewController.currentIndex != 1 {
            cameraViewController.takePicture()
            
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                // change the color
                self.tabs[previousIndex].imageView?.tintColor = Styles.Color.Secondary
                self.tabs[self.selectedIndex].imageView?.tintColor = Styles.Color.Primary
                
                // Reset image
                // Set unselected to white
                var whiteButton: UIImage? = UIImage()
                switch previousIndex {
                    case 0:
                        whiteButton = UIImage(named: Constants.Images.home)
                    case 1:
                        whiteButton = UIImage(named: Constants.Images.circle)
                    case 2:
                        whiteButton = UIImage(named: Constants.Images.user)
                    default:
                        break
                }
                self.tabs[previousIndex].setImage(whiteButton, for: .normal)
                
                // Set selected to yellow
                var yellowButton: UIImage? = UIImage()
                switch self.selectedIndex {
                    case 0:
                        yellowButton = UIImage(named: Constants.Images.homeYellow)
                    case 1:
                        yellowButton = UIImage(named: Constants.Images.circleYellow)
                    case 2:
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
