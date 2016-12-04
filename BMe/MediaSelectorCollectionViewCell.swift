//
//  VideoCompositionCollectionViewCell.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/19/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class MediaSelectorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    
    struct Key {
        static let id = "MediaSelectorCollectionViewCell"
    }
    
    let selectionMargin: CGFloat = 4.00
    let hightlightColor = Styles.Color.Primary
    let highlightCornerRadius: CGFloat = 5.00
    let selectedOpacity: Float = 0.70
    let animationDuraction: TimeInterval = 0.2
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var isVideo: Bool! {
        didSet {
            durationLabel.isHidden = !isVideo
        }
    }
    
    override var isSelected : Bool {
        didSet {
            
            UIView.animate(withDuration: animationDuraction, animations: {
                self.layer.borderColor = self.isSelected ? self.hightlightColor.cgColor : UIColor.clear.cgColor
                self.layer.borderWidth = self.isSelected ? self.selectionMargin : 0
                self.clipsToBounds = true
                self.layer.cornerRadius = self.isSelected ? self.highlightCornerRadius : 0
                self.layer.opacity = self.isSelected ? self.selectedOpacity : 1.0
            }, completion: { (success) in
                UIView.animate(withDuration: self.animationDuraction, animations: {
                    self.layer.borderWidth = self.isSelected ? self.selectionMargin / 1.25 : 0
                })
            })
        }
    }
    // MARK: - Lifecycle methods
    
    override func prepareForReuse() {
        isSelected = false
        imageView.image = nil
        isVideo = false
    }

    // MARK: - Methods
    
}
