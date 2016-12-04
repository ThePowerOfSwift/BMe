//
//  LocationButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class LocationButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        changeImageDefault()
    }

    func changeImageDefault() {
        let defaultImage = UIImage(named: Constants.Images.location)
        setImage(defaultImage, for: UIControlState.normal)
        
    }
    
    func changeImageHighlighted() {
        let highlightedImage = UIImage(named: Constants.Images.locationYellow)
        setImage(highlightedImage, for: UIControlState.normal)
    }
}
