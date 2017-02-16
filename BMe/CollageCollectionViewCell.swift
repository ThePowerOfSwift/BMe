//
//  CollageCollectionViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/16/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class CollageCollectionViewCell: UICollectionViewCell {

    // MARK: Properties
    @IBOutlet weak var imageView: UIImageView!
    
    /** Model */
    var post: Post? {
        didSet {
            didSetPost()
        }
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /**
     Common intialization called after init
     */
    private func setup() {
        // Load nib
        let view = Bundle.main.loadNibNamed(keys.nibName, owner: self, options: nil)?.first as! UIView
        // Resize to fill container
        view.frame = self.bounds
        view.autoresizingMask = .flexibleHeight
        view.autoresizingMask = .flexibleWidth
        // Add nib view to self
        self.contentView.addSubview(view)
    }
    
    private func didSetPost() {
        if let post = post {
            post.assetStorageURL(completion: { (url) in
                self.imageView.loadImageFromGS(url: url, placeholderImage: nil)
            })
        }
    }
    
    /** */
    struct keys {
        static var nibName = "CollageCollectionViewCell"
    }

}
