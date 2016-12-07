//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

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
        
        if let firstViewController = orderedViewControllers?
            .first {
            setViewControllers([firstViewController],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
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

    }
    
}

