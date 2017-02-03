//
//  View.swift
//  BMe
//
//  Created by parry on 2/1/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

@IBDesignable class CustomView : UIView {
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
