//
//  ShowImageViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/3/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController {
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the picture user took
        let pictureView = UIImageView(image: image)
        pictureView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(pictureView)
    }
}
