//
//  NewCameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/19/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit


class CameraViewController: UIViewController, SatoCameraDatasource {
    
    // MARK: SatoCamerDatasource
    // Sample buffer that shows live capture
    var sampleBufferView: UIView?
    // Image view that holds the captured image
    var outputView: UIView?
    
    // MARK: ImageEffects
    var drawEffect = DrawImageEffectViewController()
    
    // MARK: ImageEffect option containers
    @IBOutlet var effectMenuViewContainer: UIView!
    @IBOutlet var effectButtonViewContainer: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImageEffectTools()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupImageEffectTools() {
        // Draw Image Effect
        addChildViewController(drawEffect)
        drawEffect.view.frame = view.bounds
        view.addSubview(drawEffect.view)
        drawEffect.didMove(toParentViewController: self)
    }
}
