//
//  CameraPageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class CameraPageViewController: UIPageViewController {
    
    //var orderedViewControllers: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
//        setViewControllers(orderedViewControllers,
//                           direction: .forward,
//                           animated: true,
//                           completion: nil)
        print("orderedViewControllers: \(orderedViewControllers)")
        print("viewControllers: \(viewControllers)")
        
    }
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let redViewController = UIViewController()
        redViewController.view.backgroundColor = UIColor.red
        let greenViewController = UIViewController()
        greenViewController.view.backgroundColor = UIColor.green
        return [redViewController, greenViewController]
    }()

}

extension CameraPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

