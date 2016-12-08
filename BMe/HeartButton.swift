//
//  HeartButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/8/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol HeartButtonDatasource: class {
    func postID(_ sender: UIButton) -> String
}
@objc protocol HeartButtonDelegate: class {
    
}
class HeartButton: UIButton {
    private let deselectedImage = UIImage(named: Constants.Images.heartGray)
    private let selectedImage = UIImage(named: Constants.Images.hearBlue)
    private let actionType = "HeartButton"
    
    func performSelection() {
        if let datasource = datasource {
            FIRManager.shared.heartPost(datasource.postID(self))
        }
    }
    
    func performDeSelection() {
        if let datasource = datasource {
            FIRManager.shared.removeHeartPost(datasource.postID(self))
        }
    }
    
    // MARK: - template setup
    weak var datasource: HeartButtonDatasource?
    weak var delegate: HeartButtonDelegate?
    
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

