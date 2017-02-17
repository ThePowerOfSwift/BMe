//
//  PostTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/17/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var contentImageView: UIImageView!
    
    /** Model */
    var post: Post? {
        didSet {
            didSetPost()
        }
    }
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    }

    // MARK: Methods
    
    func didSetPost() {
        if let post = post {
            post.assetStorageURL(completion: { (url) in
                // Check that image loading is still needed
                if (post.ID == self.post?.ID) {
                    self.contentImageView.loadImageFromGS(url: url, placeholderImage: nil)
                }
            })
        }
    }

    // MARK: Cell behaviour
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /** */
    struct keys {
        static var nibName = "PostTableViewCell"
    }

    
}
