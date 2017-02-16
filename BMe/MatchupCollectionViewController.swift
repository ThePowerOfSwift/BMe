//
//  MatchupCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/14/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

private let reuseIdentifier = MatchupCollectionViewCell.keys.nibName

/** 
 Displays Matchups using a banner style rotating carousel
 */
class MatchupCollectionViewController: UICollectionViewController, MatchupCollectionViewCellDelegate {
    
    /** Model */
    var matchups: [Matchup]!
    
    // MARK: Lifecycle methdos

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(MatchupCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MatchupCollectionViewCell
    
        let matchup = matchups[indexPath.row]
        
        // Configure the cell model etc.
        cell.matchup = matchup
        cell.delegate = self
        
        return cell
    }
    
    // MARK: CollectionView paging methods

    /** Scroll to the next item */
    func advanceItem(_ sender: UICollectionViewCell) {
        // Assumes there is only one section
        if let currentIdx = collectionView?.indexPath(for: sender) {
            let count = collectionView(collectionView!, numberOfItemsInSection: currentIdx.section) - 1
            
            if (currentIdx.row < count) {
                let nextIdx = IndexPath(row: currentIdx.row + 1, section: currentIdx.section)
                self.collectionView?.scrollToItem(at: nextIdx, at: .left, animated: true)
            }
        }
    }
    
    // MARK: MatchupCollectionViewCellDelegate
    
    /** 
     Delegate method.  Upon proc advances the collectionview to the next item.
     */
    func didSelect(_ sender: MatchupCollectionViewCell) {
        advanceItem(sender)
    }
}
