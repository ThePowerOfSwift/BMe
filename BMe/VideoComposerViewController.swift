//
//  VideoComposerViewController.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/19/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class VideoComposerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

// MARK: - Outlets
    
    @IBOutlet weak var containerAView: UIView!
    @IBOutlet weak var containerBView: UIView!
    
// MARK: - Variables
    
    // Container views
    var template: VideoComposition?
    let compositionVC = UIStoryboard(name: Constants.VideoCompositionStoryboard.ID, bundle: nil).instantiateViewController(withIdentifier: Constants.VideoCompositionStoryboard.videoCompositionViewController) as! VideoCompositionViewController
    var browser = UIImagePickerController()
    
    // Pan Gesture
    var originalPanPoint: CGPoint!
    var currentPanView: UIView!
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Browser
        browser = configuredImagePicker()
        browser.delegate = self
        addChildViewController(browser)
        browser.view.frame = containerAView.bounds
        browser.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerAView.addSubview(browser.view)
        browser.didMove(toParentViewController: self)
        
        // Composition VC
        compositionVC.videoComposition = template
        // add child view controller
        addChildViewController(compositionVC)
        // add subview
        compositionVC.view.frame = containerBView.bounds
        compositionVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerBView.addSubview(compositionVC.view)
        // did move to parent
        compositionVC.didMove(toParentViewController: self)
        
        // Pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        view.addGestureRecognizer(pan)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

// MARK: - Gesture methods
    
    func onPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let point = panGestureRecognizer.location(in: view)
//        let translation = panGestureRecognizer.translation(in: view)
        
        switch panGestureRecognizer.state {
        case .began:
            print("Pan began")
            originalPanPoint = point
            if let panView = panGestureRecognizer.view {
                
                /*
                // Make draggable UIView
                currentPanView = panView.copy() as! UIView
                
                let pan = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
                currentPanView.addGestureRecognizer(pan)
                currentPanView.isUserInteractionEnabled = true
                currentPanView.center = point
                view.addSubview(currentPanView)
                 */
            }
        case .cancelled:
            break
        case .changed:
            print("Pan changed")
            // Draggable UIView
//            currentPanView.center = point
        case .ended:
            print("Pan ended")
            // Find end point
            
            // Draggable UIView
//            currentPanView.removeFromSuperview()
        case .failed:
            break
        case .possible:
            break
        }
    }


}
