//
//  MoveableCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "VideoComposerCollectionViewCell"

class MoveableCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

//MARK: - Models
    var phAssets: PHFetchResult<PHAsset>!
    
    let imgManager = PHCachingImageManager.default()

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(VideoComposerCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - CollectionView Datasource methods
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = phAssets[indexPath.row]
        //        let mediaType = asset.mediaType
        //        if mediaType == .image {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoComposerCollectionViewCell", for: indexPath) as! VideoComposerCollectionViewCell
        
        cell.tag = indexPath.row
        cell.backgroundColor = UIColor.blue
        imgManager.requestImage(for: asset, targetSize: Constants.Layout.compositionSize, contentMode: .aspectFill, options: nil, resultHandler: { (image: UIImage?, info:[AnyHashable : Any]?) in
            if cell.tag == indexPath.row {
                //                    cell.image = image
            }
        })
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
// MARK: - CollectionView FlowLayout Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.Layout.compositionSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
}
