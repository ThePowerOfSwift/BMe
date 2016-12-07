//
//  CrossButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class CrossButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setImageDefault()
    }
    
    func setImageDefault() {
        let defaultImage = UIImage(named: Constants.Images.cross)
        setImage(defaultImage, for: UIControlState.normal)
    }
    
    func setImageYellow() {
        let defaultImage = UIImage(named: Constants.Images.crossYellow)
        setImage(defaultImage, for: UIControlState.normal)
    }
}
