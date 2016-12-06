//
//  BusyView.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class BusyView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var hookImageView: UIImageView!
    @IBOutlet weak private var hookAnimationImageView: UIImageView!
    
    // model
    var animate = false
    var selectedImageIndex = 0
    let images = [UIImage(named: Constants.Images.hookBlue),
                  UIImage(named: Constants.Images.hook)
                  ]
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        // Load nib
        Bundle.main.loadNibNamed("BusyView", owner: self, options: nil)
        addSubview(self.view)
        isHidden = true
        
        // Set size and default properties
        self.view.backgroundColor = UIColor.clear
        self.view.frame.size = Styles.BusyIndicator.size
        isUserInteractionEnabled = false
        self.view.layer.cornerRadius = Styles.Shapes.cornerRadius
        self.view.clipsToBounds = true
        
        // Blur background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.view.insertSubview(blurEffectView, at: 0)
    }

    func startAnimating() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        isHidden = false
        animate = true
        animate(animate)
    }
    func stopAnimating() {
        animate = false
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    func animate(_ alpha: Bool)
    {
        UIView.animate(withDuration: Styles.BusyIndicator.duration, animations: {
            self.hookAnimationImageView.alpha = CGFloat(alpha.hashValue)
        }, completion: { (success) in
            DispatchQueue.main.async {
            // change image
                    self.hookAnimationImageView.image = self.images[self.selectedImageIndex]
                    self.selectedImageIndex += 1
                    self.selectedImageIndex = self.selectedImageIndex % self.images.count
                if success && self.animate {
                    self.animate(!alpha)
                }
                if !self.animate {self.isHidden = true}
            }
        })
    }
}
