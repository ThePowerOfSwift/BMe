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

class PageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]?
    
    var pageViewDelegate: PageViewDelegate?
    var lastContentOffset: CGFloat = 0
    
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
        

        
        // load all the vc
//        var count = 0
//        for vc in orderedViewControllers! {
//            //let view = vc.view
//            print("\(count) isViewLoaded? : \(isViewLoaded)")
//            count += 1
//        }
//        let mediaSelectorNVC = orderedViewControllers?[1] as! UINavigationController
//        let mediaSelectorVC = mediaSelectorNVC.viewControllers[0] as! MediaSelectorViewController
//        let view = mediaSelectorVC.view
//        
//        for vc in viewControllers! {
//            print("vc: \(vc)")
//        }
        
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
        print("in viewControllerBefore")
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

        print("in viewControllerAfter")
        return orderedViewControllers?[nextIndex]
    }
    // http://stackoverflow.com/questions/8751633/how-can-i-know-if-uipageviewcontroller-flipped-forward-or-reversed
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Get current index
        let pageContentViewController = pageViewController.viewControllers![0]
        currentIndex = (orderedViewControllers?.index(of: pageContentViewController))!
        
        // Move title scroll view to the current index
        if completed {
            pageViewDelegate?.scrollTitleTo(index: currentIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("willTransitionTo")

    }
    
}

// for disable bouncing. put this in viewDidLoad
//        for view in view.subviews {
//            if view is UIScrollView {
//                (view as! UIScrollView).delegate =  self
//                //(view as! UIScrollView).alwaysBounceHorizontal = false
////                (view as! UIScrollView).bounces = false
////                print("(view as! UIScrollView).isScrollEnabled): \(view as! UIScrollView).isScrollEnabled))")
//                break
//            }
//        }



// Disable bouncing
//// http://stackoverflow.com/questions/21798218/disable-uipageviewcontroller-bounce
//extension PageViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
//        } else if currentIndex == (orderedViewControllers?.count)! - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
//        }
//        
//    }
//    
//    private func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: CGPoint) {
//        if currentIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: CGFloat(0))
//        } else if currentIndex == (orderedViewControllers?.count)! - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: CGFloat(0))
//        }
//
//    }
//    
//    // for bouncing
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("bouncing back")
//        if currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
//        } else if currentIndex == (orderedViewControllers?.count)! - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
//            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
//        }
//    }
//}






