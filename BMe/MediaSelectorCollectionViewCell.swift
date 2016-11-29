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
    @IBOutlet weak var videoIconView: UIImageView!
    
    struct Key {
        static let id = "MediaSelectorCollectionViewCell"
    }
    
    let selectionMargin: CGFloat = 2.00
    let hightlightColor = UIColor.yellow
    let highlightCornerRadius: CGFloat = 3.00
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var isVideo: Bool! {
        didSet {
            videoIconView.isHidden = !isVideo
        }
    }
    
    override var isSelected : Bool {
        didSet {
            self.layer.borderColor = isSelected ? hightlightColor.cgColor : UIColor.clear.cgColor
            self.layer.borderWidth = isSelected ? selectionMargin : 0
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
