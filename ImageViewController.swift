//
//  ImageViewController.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/26/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image: UIImage?
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        let imageView = UIImageView(image: image)
        imageView.frame = view.frame
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(imageView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedImage(sender:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    internal func tappedImage(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
