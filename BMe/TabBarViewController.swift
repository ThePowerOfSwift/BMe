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
    @IBOutlet weak var titleScrollView: UIScrollView!
    @IBOutlet weak var titleBar: UIView!

    
    // MARK: Properties
    var browseViewController: UIViewController!
    var browsePageViewController: PageViewController!
    var cameraNavigationController: UINavigationController!
    var cameraViewController: CameraViewController!
    var cameraPageViewController: PageViewController!
    var createViewController: UINavigationController!
    var accountViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = Constants.TabBar.selectedIndex  // tag value from selected UIButton

    // original tab position to show tabbar with animation
    var tabOriginalCenterYPositions: [CGFloat] = [CGFloat]()
    
    // To layout each tab button correctly
    var boxWidth: CGFloat { return view.frame.width / CGFloat(tabs.count) } // Get the width of each "box" by dividing view by 3
    var centerOffset: CGFloat { return boxWidth / 2 }   // Get the center offset in box
    
    // detect if it is just after app started. if so, don't enable camera button to take picture
    var isInitialStartup: Bool = true
    // labels that show title at the top
    var titlePages: [UILabel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()

        setupTabs()
        layoutTabs()
        
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
    
    // MARK: View Controller Initial Setup
    
    func setupViewControllers() {
        // MARK: TODO refactor
        // Browse view controller
        browseViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Browser, bundle: nil).instantiateInitialViewController()
        browsePageViewController = UIStoryboard(name: Constants.SegueID.Storyboard.PageView, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.PageViewController) as! PageViewController
        addChildViewController(browsePageViewController)
        
        let secondVC = UIStoryboard(name: Constants.SegueID.Storyboard.Featured, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.FeaturedViewController)
        browsePageViewController.orderedViewControllers = [browseViewController, secondVC]
        
        // Create view controller which will be in camera page view controller
        let createStoryboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        createViewController = createStoryboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.mediaSelectorNavigationController) as! UINavigationController
        
        let mediaSelectorVC = createViewController.viewControllers.first as! MediaSelectorViewController
        
        // Preload media selector vc's view for smooth transition in page view controller
        _ = mediaSelectorVC.view
        
        // Camera view controller which will be in camera page view controller
        cameraNavigationController = UIStoryboard(name: Constants.SegueID.Storyboard.Camera, bundle: nil).instantiateInitialViewController() as! UINavigationController
        cameraViewController = cameraNavigationController.viewControllers.first as! CameraViewController
        
        cameraViewController.tabBarViewControllerDelegate = self
        
        // Camera page view controller
        cameraPageViewController = UIStoryboard(name: Constants.SegueID.Storyboard.PageView, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.PageViewController) as! PageViewController
        cameraPageViewController.orderedViewControllers = [cameraViewController, createViewController]
        addChildViewController(cameraPageViewController)
        
        // Account view controller
        accountViewController = UIStoryboard(name: Constants.SegueID.Storyboard.Account, bundle: nil).instantiateInitialViewController()
        addChildViewController(accountViewController)
        
        // Init with view controllers
        viewControllers = [browsePageViewController, cameraPageViewController, accountViewController]
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
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: Constants.PageTitles.fontSize)
            titleLabel.textColor = Styles.Color.Tertiary
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.text = titles[i]
            titleScrollView.addSubview(titleLabel)
            titlePages?.append(titleLabel)
        }
        titleScrollView.contentSize = CGSize(width: titleScrollView.frame.width * CGFloat(titles.count), height: titleScrollView.frame.size.height)
    }
    
    // MARK: Tab Setups
    // Call setupButtons(imageName, tabIndex) to setup tabs
    func setupTabs() {
        setupTab(imageName: Constants.Images.home, tabIndex: Tab.Browse.rawValue)
        setupTab(imageName: Constants.Images.circle, tabIndex: Tab.Camera.rawValue)
        setupTab(imageName: Constants.Images.user, tabIndex: Tab.Account.rawValue)
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
        layoutTab(index: Tab.Browse.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: Tab.Camera.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        layoutTab(index: Tab.Account.rawValue, w: Constants.TabBar.unselectedTabSize, h: Constants.TabBar.unselectedTabSize)
        
        // Get original tab position to show tabbar with animation
        for tab in tabs {
            tabOriginalCenterYPositions.append(tab.center.y)
        }
    }
    
    func layoutTab(index: Int, w: CGFloat, h: CGFloat) {

        let y: CGFloat = view.frame.height - Constants.TabBar.unselectedTabSize
        var x: CGFloat = 0
        
        // Set only width and height
        tabs[index].frame = CGRect(x: CGRect.zero.origin.x, y: CGRect.zero.origin.y, width: w, height: h)
        
        // Get the center x coordinate
        if index == Tab.Browse.rawValue {
            x = centerOffset
        } else {
            x = centerOffset + boxWidth * CGFloat(index)
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
        
        // Show title scroll label if selected index is 1
        if selectedIndex != previousIndex || isInitialStartup {
            switch selectedIndex {
            case Tab.Browse.rawValue:
                changeTitleLabels(titles: Constants.PageTitles.browsePageTitles)
                showScrollTitle()
            case Tab.Camera.rawValue:
                changeTitleLabels(titles: Constants.PageTitles.cameraPageTitles)
                showScrollTitle()
            default:
                hideScrollTitle()
            }
        } 
        
        // Take picture when cameraButton tapped again in camera view (disabled in compose view)
        if previousIndex == Tab.Camera.rawValue && selectedIndex == Tab.Camera.rawValue && !isInitialStartup && cameraPageViewController.currentIndex != 1 {
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

extension TabBarViewController: PageViewDelegate {
    
    func setupAlphaAt(index: Int) {
        
        guard let titlePages = titlePages else { return }
        
        for i in 0..<titlePages.count {
            if i != index {
                UIView.animate(withDuration: Constants.TabBar.titleTextFadeAwayAnimationDuration, animations: {
                    titlePages[i].alpha = Constants.TabBar.titleTextMinAlpha
                })
            }
        }
    }
    
    func scrollTitleTo(index: Int) {
        let point = CGPoint(x: titleScrollView.frame.width * CGFloat(index), y: 0)
        titleScrollView.setContentOffset(point, animated: true)
        
        guard let titlePages = titlePages else { return }
        
        // Display title text corresponding to page
        for i in 0..<titlePages.count {
            if i == index {
                UIView.animate(withDuration: Constants.TabBar.titleTextFadeAwayAnimationDuration, animations: {
                    titlePages[i].alpha = Constants.TabBar.titleTextMaxAlpha
                })
            } else {
                UIView.animate(withDuration: Constants.TabBar.titleTextFadeAwayAnimationDuration, animations: {
//                    titlePages[i].alpha = 0.2
                })
            }
        }
        
        // animate bar
        UIView.animate(withDuration: Constants.TabBar.titleBarBlinkAnimationDuration, animations: {
            self.titleBar.alpha = Constants.TabBar.titleTextMaxAlpha
        }, completion: { (completed :Bool) in
            UIView.animate(withDuration: Constants.TabBar.titleBarBlinkAnimationDuration, animations: {
                titlePages[index].alpha = Constants.TabBar.titleTextMinAlpha
                self.titleBar.alpha = 0
            })
        })
    }
}

extension TabBarViewController: TabBarViewControllerDelegate {
    
    func showScrollTitle() {
        titleScrollView.isHidden = false
        titleBar.isHidden = false
    }
    
    func hideScrollTitle() {
        titleScrollView.isHidden = true
        titleBar.isHidden = true
    }
    
    // Show and hide tab bar
    func showTabBar() {
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions[i]
            }
        })
    }
    
    func hideTabBar() {
        UIView.animate(withDuration: Constants.TabBar.tabbarShowAnimationDuration, animations: {
            for i in 0..<self.tabs.count {
                self.tabs[i].center.y = self.tabOriginalCenterYPositions[i] + CGFloat(Constants.TabBar.selectedTabSize) + 20
            }
        })
    }
}
