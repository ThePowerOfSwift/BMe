//
//  VideoTableViewCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/23/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    static let identifier = "VideoTableViewCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Configure collection view's cell from VideoCollectionViewCell.xib
        let nib = UINib(nibName: "VideoCollectionViewCell", bundle:nil)
        collectionView.register(nib, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        
    }

    // A method to set collection view's delegate to table view controller using delegate composition
    func setCollectionViewDataSourceDelegate <D: UICollectionViewDataSource & UICollectionViewDelegate> (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.dataSource = dataSourceDelegate
        collectionView.delegate = dataSourceDelegate
        collectionView.tag = row // Itentifiy which table view cell this collection view is in
        collectionView.reloadData() // To refresh https://github.com/ashfurrow/Collection-View-in-a-Table-View-Cell/issues/1
    }
    
}
