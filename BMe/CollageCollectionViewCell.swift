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
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // Add nib view to self
        self.contentView.addSubview(view)
        
        // Testing
        // Random background color
        let r: Float = Float(arc4random()) / Float(UInt32.max)
        let g: Float = Float(arc4random()) / Float(UInt32.max)
        let b: Float = Float(arc4random()) / Float(UInt32.max)
        self.backgroundColor = UIColor(colorLiteralRed: r, green: g, blue: b, alpha: 1.00)
    }
    
    private func didSetPost() {
        if let post = post {
            post.assetStorageURL(completion: { (url) in
                // Check that image loading is still needed
                if (post.ID == self.post?.ID) {
                    self.imageView.loadImageFromGS(url: url, placeholderImage: nil)
                }
            })
        }
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    /** */
    struct keys {
        static var nibName = "CollageCollectionViewCell"
    }

}
