//
//  RainCheckButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/7/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol RainCheckButtonDatasource: class {
    
}
@objc protocol RainCheckButtonDelegate: class {
    
}
class RainCheckButton: UIButton {
    private let deselectedImage = UIImage(named: Constants.Images.raincheckClosed)
    private let selectedImage = UIImage(named: Constants.Images.raincheckBlue)
    private let actionType = "Raincheck"
    
    func performSelection() {
        
    }
    
    func performDeSelection() {
        
    }

// MARK: - template setup
    weak var datasource: RainCheckButtonDatasource?
    weak var delegate: RainCheckButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setImage(deselectedImage, for: .normal)
        setImage(selectedImage, for: .selected)
        addTarget(self, action: #selector(tapped), for: UIControlEvents.touchUpInside)
    }
    
    func tapped() {
        isSelected = !isSelected
        if isSelected {
            print("Selecting \(actionType)")
            performSelection()
        }
        else {
            print("De-selecting \(actionType)")
            performDeSelection()
        }
    }
}
