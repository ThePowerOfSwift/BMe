//
//  VideoComposerCollectionViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class VideoComposerCollectionViewCell: UICollectionViewCell {
    override func prepareForReuse() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
