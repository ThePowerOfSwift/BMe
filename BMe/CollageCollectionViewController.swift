//
//  CollageCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/16/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = PostCollectionViewCell.keys.nibName
private let cellClass = PostCollectionViewCell.self

class CollageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    /** Model */
    var posts:[Post]! = []
    
    // FIR
    fileprivate var _refHandle: FIRDatabaseHandle?
    private var database = FIR.manager.databasePath(.post)
    private var isFetchingData = false
    private let fetchBatchSize = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        if let posts = posts {
            return posts.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
    
        // Configure the cell
        cell.post = posts[indexPath.row]
        
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout
    private let spacing: CGFloat = 0.00
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let row = indexPath.row
        let viewSize = collectionView.frame.size
        var itemSize: CGSize
        
        switch row {
        case 0:
            var width: CGFloat = 2 * (viewSize.width / 3)
            width -= spacing
            let height: CGFloat = width
            
            itemSize = CGSize(width: width, height: height)
        
        default:
            var width: CGFloat = viewSize.width / 3
            width -= spacing
            let height: CGFloat = width
            
            itemSize = CGSize(width: width, height: height)
        }
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    // MARK: FIR Methods
    
    func setupDatasource() {
        // Setup datasource
        if let _refHandle = _refHandle {
            database.removeObserver(withHandle: _refHandle)
        }
        self.posts.removeAll()
        self.collectionView?.reloadData()
        
        // Reverse load posts from most recent onwards
        _refHandle = database.queryLimited(toLast: UInt(fetchBatchSize)).observe(.childAdded, with: { (snapshot) in
            self.posts.insert(Post(snapshot), at: 0)
            self.collectionView?.insertItems(at: [IndexPath(row: 0, section: 0)])
        })
    }
    
    // Deregister for notifications
    deinit {
        database.removeObserver(withHandle: _refHandle!)
    }
    
    /* not tested
    // Performs a fetch to get more data
    func fetchMoreDatasource() {
        if !isFetchingData {
            isFetchingData = true
            
            // Get the "next batch" of posts
            // Request with upper limit on the last loaded post with a lower limit bound by batch size
            let lastPost = posts[posts.count - 1]
            database.queryEnding(atValue: lastPost.ID).queryLimited(toLast: UInt(fetchBatchSize)).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    
                    // returns posts oldest to youngest, inclusive, so remove last child
                    // and reverse to revert to youngest to oldest order (or reverse and remove first child)
                    var ignoreFirst = true
                    for child in snapshot.children.reversed() {
                        if ignoreFirst { //ignore reference post and add the rest
                            ignoreFirst = false
                        }
                        else {
                            let post = Post(child as! FIRDataSnapshot)
                            // append data
                            self.posts.append(post)
                            // load into tv
                            self.collectionView?.insertItems(at: [IndexPath(row: self.posts.count - 1, section: 0)])                                
                        }
                    }
                    self.isFetchingData = false
            })
        }
    }
 */
}
