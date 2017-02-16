//
//  CompareCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/14/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

// TODO: let the cell be dynamically set at init
private let reuseIdentifier = AssetCompareCollectionViewCell.keys.nibName

class BannerCollectionViewController: UICollectionViewController {
    
    // Model
    var matchups: [Matchup]!
    
    // MARK: Lifecycle methdos

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(AssetCompareCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        // Make it paging
        self.collectionView?.isPagingEnabled = true
        // Color background to white (default is black)
        self.collectionView?.backgroundColor = UIColor.white
        
        // Load model
        Matchup.dailyMatchups { (matchups) in
            self.matchups = matchups
            self.collectionView?.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return count of matchups only after it's loaded
        if let matchups = matchups {
            return matchups.count
        }
        else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCompareCollectionViewCell
    
        let matchup = matchups[indexPath.row]
        
        // Configure the cell
        cell.matchup = matchup
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    /*
    All delegate touches are intercepted by the custom cell
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
     */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
