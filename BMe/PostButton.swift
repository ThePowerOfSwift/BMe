//
//  PostButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class PostButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setImageDefault()
        clipsToBounds = false
        
        // Programatically makes border
        // Make enclosing view with borders
        let borderBuffer: CGFloat = 10
        let borderView = UIView(frame: bounds.insetBy(dx: -borderBuffer, dy: -borderBuffer))
        borderView.layer.borderWidth = 4
        borderView.layer.cornerRadius = 10
        borderView.layer.borderColor = Styles.Color.Tertiary.cgColor
        addSubview(borderView)
    }
    
    func setImageDefault() {
        let defaultImage = UIImage(named: Constants.Images.hookYellow)
        setImage(defaultImage, for: UIControlState.normal)
    }
}
