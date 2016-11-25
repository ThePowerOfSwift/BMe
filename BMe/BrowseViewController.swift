//
//  BrowseViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let model: [[UIColor]] = generateRandomData() // for dummy data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configure table view's cell from VideoTableViewCell.xib
        let nib = UINib(nibName: "VideoTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: VideoTableViewCell.identifier)
        
        
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier, for: indexPath)
        return cell
        
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? VideoTableViewCell else { return }
        
        // Set delegate and data source of a collection view in this table view to this view controller (BrowseViewController)
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
    }
}

extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return model[collectionView.tag].count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath)
        cell.backgroundColor = model[collectionView.tag][indexPath.item]
        
        //        let frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: self.view.frame.width, height: self.view.frame.width/2)
        //        cell.frame = frame
        
        return cell
    }
    
    // Need to conform UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.width/2)
        return size
    }
    
    //Use for interspacing
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
}
