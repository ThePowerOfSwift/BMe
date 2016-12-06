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
    }
    
    func setImageDefault() {
        // TODO: - CHANGE TO WHITE
        let defaultImage = UIImage(named: Constants.Images.hook)
        setImage(defaultImage, for: UIControlState.normal)
    }
    
    func setImageYellow() {
//        let defaultImage = UIImage(named: Constants.Images.crossYellow)
//        setImage(defaultImage, for: UIControlState.normal)
    }


}
