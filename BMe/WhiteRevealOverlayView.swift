//
//  WhiteRevealOverlayView.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class WhiteRevealOverlayView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

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
        Bundle.main.loadNibNamed("WhiteRevealOverlayView", owner: self, options: nil)
        addSubview(self.view)

        isUserInteractionEnabled = false
        
        view.backgroundColor = UIColor.clear
        
        overlayView.alpha = 0.05
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = overlayView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 0.7]
        overlayView.layer.addSublayer(gradientLayer)
    }
}
