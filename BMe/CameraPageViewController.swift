//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol CameraPageDelegate {
    @objc optional func scrollTitleTo(index: Int)
}

class CameraPageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]?
    var cameraViewController: CameraViewController?
    
    var cameraPageDelegate: CameraPageDelegate?
    var lastContentOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        
        if let firstViewController = orderedViewControllers?
            .first {
            cameraViewController = firstViewController as? CameraViewController

            setViewControllers([firstViewController],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }

        // Scroll view delegate
        for view in self.view.subviews{
            if view is UIScrollView {
                (view as! UIScrollView).delegate = self
            }
        }
    }
}

extension CameraPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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
        let previousViewControllerIndex = orderedViewControllers?.index(of: previousViewControllers.first!)
        
        // Get current index
        let pageContentViewController = pageViewController.viewControllers![0]
        let index = orderedViewControllers?.index(of: pageContentViewController)
        
        // Move title scroll view to the current index
        if completed {
            cameraPageDelegate?.scrollTitleTo!(index: index!)
        }
        
        print("Completed: \(completed). Current index: \(index!). Previous Index: \(previousViewControllerIndex!)\n")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let pendingViewControllerIndex = orderedViewControllers?.index(of: pendingViewControllers.first!)
        print("Start. pendingViewControllerIndex: \(pendingViewControllerIndex!)\n")
    }
    
}

extension CameraPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("self.lastContentOffset: \(self.lastContentOffset)")
        if (self.lastContentOffset > scrollView.contentOffset.x) {
            //let offset = scrollView.contentOffset.x - self.lastContentOffset
            //print("Moving right. contentOffset.x: \(scrollView.contentOffset.x)\t real offset: \(offset)")
            //cameraPageDelegate?.animatePhotoToCenter!(offset: offset)
        }
        else if (self.lastContentOffset < scrollView.contentOffset.x) {
            //let offset = scrollView.contentOffset.x - self.lastContentOffset
            //print("Moving left. contentOffset.x: \(scrollView.contentOffset.x)\t real offset: \(offset)")
            //cameraPageDelegate?.animateComposeToCenter!(offset: offset)
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.x
    }
    

}

