//
//  CollageCollectionViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/16/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

private let reuseIdentifier = CollageCollectionViewCell.keys.nibName

class CollageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    /** Model */
    var posts:[Post]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(CollageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        // Color background to white (default is black)
        self.collectionView?.backgroundColor = UIColor.white

        // Load model
        // TODO: change model
        // TODO: verify order of posts
        FIR.manager.databasePath(.post).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            let post = Post(snapshot)
            self.posts.append(post)
            self.collectionView?.reloadData()
        })
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollageCollectionViewCell
    
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
}
