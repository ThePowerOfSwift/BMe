//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

// http://stackoverflow.com/questions/11659604/preloading-pages-of-uipageviewcontroller
// for preloading view controllers for smooth paging

import UIKit

protocol PageViewDelegate {
    func scrollTitleTo(index: Int)
    func setupAlphaAt(index: Int)
}

class PageViewController: UIPageViewController, UIGestureRecognizerDelegate {
    
    var orderedViewControllers: [UIViewController]?
    
    var pageViewDelegate: PageViewDelegate?    
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers?.first {
            setViewControllers([firstViewController],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
        
        // loop over your pageViewController gestures
        
        for gesture in gestureRecognizers {
            // get the good one, i discover there are 2
            if(gesture is UIPanGestureRecognizer)
            {
                // replace delegate by yours (Do not forget to implement the gesture protocol)
                (gesture as! UIPanGestureRecognizer).delegate = self
            }
        }

    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // add custom logic
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageViewDelegate?.setupAlphaAt(index: currentIndex)
        pageViewDelegate?.scrollTitleTo(index: currentIndex)
    }
    
    
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard (orderedViewControllers?.count)! > previousIndex else {
            return nil
        }
        
        return orderedViewControllers?[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers?.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        return orderedViewControllers?[nextIndex]
    }
    
    // http://stackoverflow.com/questions/8751633/how-can-i-know-if-uipageviewcontroller-flipped-forward-or-reversed
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Get current index
        let pageContentViewController = pageViewController.viewControllers!.first
        currentIndex = (orderedViewControllers?.index(of: pageContentViewController!))!
        
        // Move title scroll view to the current index
        if completed {
            pageViewDelegate?.scrollTitleTo(index: currentIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

    }
}

// When drawing, scrolling should be off
extension PageViewController: PageViewControllerDelegate {
    
    func disableScrolling() {
        for view in view.subviews {
            if let view = view as? UIScrollView {
                view.isScrollEnabled = false
            }
        }
    }
    
    func enableScrolling() {
        for view in view.subviews {
            if let view = view as? UIScrollView {
                view.isScrollEnabled = true
            }
        }
    }
}
