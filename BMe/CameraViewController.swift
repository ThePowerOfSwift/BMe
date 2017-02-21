//
//  NewCameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/19/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

/*protocol CameraViewControllerDatasource {
    
}*/

class CameraViewController: UIViewController, SatoCameraDatasource {
    
    /** Model */
    let satoCamera = SatoCamera()

    // MARK: SatoCamerDatasource
    /** Sample buffer that shows live capture */
    @IBOutlet var sampleBufferView: UIView!
    /** Image view that holds the captured image */
    @IBOutlet var outputView: UIView!
    
    // MARK: ImageEffects
    var drawEffect = DrawImageEffectViewController()
    
    // MARK: ImageEffect option containers
    @IBOutlet var effectMenuViewContainer: UIView!
    @IBOutlet var effectButtonViewContainer: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSatoCamera()
        setupImageEffectTools()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSatoCamera() {
        satoCamera.datasource = self
    }
    
    func setupImageEffectTools() {
        // Draw Image Effect
    }
}
