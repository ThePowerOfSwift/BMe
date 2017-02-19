//
//  MatchupCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/14/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = MatchupCollectionViewCell.keys.nibName
private let cellClass = MatchupCollectionViewCell.self

/**
 Displays Matchups using a banner style rotating carousel
 */
class MatchupCollectionViewController: UICollectionViewController, MatchupCollectionViewCellDelegate {
    
    // MARK: Properties

    /** Model */
    var matchups: [Matchup] = []
    
    // FIR
    fileprivate var _refHandle: FIRDatabaseHandle?
    private var database = Matchup.database()
    private var isFetchingData = false
    private let fetchBatchSize = 10

    
    // MARK: Lifecycle methdos

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        // Make it paging
        self.collectionView?.isPagingEnabled = true
        // Color background to white (default is black)
        self.collectionView?.backgroundColor = UIColor.white
        
        setupDatasource()
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
        return matchups.count
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
    
    // MARK: FIR
    
    func setupDatasource() {
        if let _refHandle = _refHandle {
            database.removeObserver(withHandle: _refHandle)
        }
        self.matchups.removeAll()
        self.collectionView?.reloadData()
        
        // Reverse load posts from most recent onwards
        _refHandle = database.queryLimited(toLast: UInt(fetchBatchSize)).observe(.childAdded, with: { (snapshot) in
            self.matchups.insert(Matchup(snapshot), at: 0)
            self.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
        })
    }
}
