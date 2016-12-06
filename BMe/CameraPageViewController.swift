//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class CameraPageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]?
    var cameraViewController: CameraViewController?
    var lastContentOffset: CGFloat = 0
    
    var originalXposition: CGFloat = 0
    var originalYposition: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        
        if let firstViewController = orderedViewControllers?
            .first {
            cameraViewController = firstViewController as! CameraViewController

            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        //originalXposition = (cameraViewController?.titleLabel?.frame.origin.x)!
        originalXposition = UIScreen.main.bounds.width / 2
        originalYposition = (cameraViewController?.titleLabel?.frame.origin.y)! + 20
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
// http://stackoverflow.com/questions/28241356/get-scroll-position-of-uipageviewcontroller
extension CameraPageViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("self.lastContentOffset: \(self.lastContentOffset)")
        if (self.lastContentOffset > scrollView.contentOffset.x) {
            
            print("Moving right. contentOffset.x: \(scrollView.contentOffset.x)")
            let offset = scrollView.contentOffset.x - self.lastContentOffset
            print("new offset: \(offset)")
            let newXposition = scrollView.contentOffset.x - originalXposition
            print("new x position: \(newXposition)")
            cameraViewController!.titleLabel!.center = CGPoint(x: newXposition, y: originalYposition)
            
        }
        else if (self.lastContentOffset < scrollView.contentOffset.x) {

            print("Moving left. contentOffset.x: \(scrollView.contentOffset.x)")
            let offset = originalXposition - self.lastContentOffset
            print("new offset: \(offset)")
            let newXposition = scrollView.contentOffset.x - originalXposition
            print("new x position: \(newXposition)")
            cameraViewController!.titleLabel!.center = CGPoint(x: newXposition, y: originalYposition)
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.x
    }

}
