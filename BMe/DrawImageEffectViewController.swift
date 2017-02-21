//
//  DrawImageEffectViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/20/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class DrawImageEffectViewController: UIView, ImageEffectMenuView {
    
    /** Model */
    var drawView = DrawView()
    
    // MARK: ImageEffectMenuView
    var buttonView = UIButton()
    var menuView: UIView? = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        drawView.frame = bounds
        drawView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(drawView)
    }
    
}
