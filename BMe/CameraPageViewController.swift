//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol CameraPageDelegate {
    @objc optional func animatePhotoToCenter(offset: CGFloat)
    @objc optional func animateComposeToCenter(offset: CGFloat)
}

class CameraPageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]?
    var cameraViewController: CameraViewController?
    
    var cameraPageDelegate: CameraPageDelegate?
    var lastContentOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        
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
        return orderedViewControllers?[nextIndex]
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

