//
//  HeartButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/8/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol FIRButtondatasource: class {
}
@objc protocol FIRButtonDelegate: class {
}

/** 
 Wrapper superclass for buttons that effect FIR events (e.g. "Like" button)
 */
class FIRButton: UIButton {
    /** Deselected image */
    private let deselectedImage = UIImage(named: "")
    /** Selected image */
    private let selectedImage = UIImage(named: "")
    
    func performSelection() {
//        if let datasource = datasource {
//        }
    }
    
    func performDeSelection() {
//        if let datasource = datasource {
//        }
    }
    
    // MARK: - template setup
    weak var datasource: FIRButtondatasource?
    weak var delegate: FIRButtonDelegate?
    
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
            performSelection()
        }
        else {
            performDeSelection()
        }
    }
}

