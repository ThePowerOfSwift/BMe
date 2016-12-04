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
        
//        let codeImageView = UIImageView()
//        codeImageView.image = image
//        
//        let scale = view.frame.width / (image?.size.width)!
//        let rect = CGRect(x: 0, y: 0, width: (image?.size.width)! * 0.8 , height: (image?.size.height)! * 0.8)
//        
//        print("Image width: \(image?.size.width)")
//        print("Image height: \(image?.size.height)")
//        print("View witdth: \(view.frame.size.width)")
//        print("View height: \(view.frame.size.height)")
//        codeImageView.frame = rect
//        codeImageView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
//        view.addSubview(codeImageView)
    }
    
}
