//
//  ViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/20/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol SatoCameraDatasource {
    var sampleBufferView: UIView! { get set }
    var outputView: UIView!{ get set }
}
