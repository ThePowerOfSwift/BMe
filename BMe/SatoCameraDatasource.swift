//
//  ViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/20/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol SatoCameraDatasource {
    /** Sample buffer that shows live capture from camera */
    var sampleBufferView: UIView! { get set }
    /** View that holds the captured image */
    var outputView: UIView!{ get set }
}
