//
//  ShowImageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/3/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Get the picture user took
    }
    
}
