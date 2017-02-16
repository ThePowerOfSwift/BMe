//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/15/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // Properties
    /** Model */
    private var cellHeights: [CGFloat] {
        get {
            return [tableView.frame.width,
                    tableView.frame.width
            ]
        }
    }

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure top (Nav Bar and TVC behaviour)
        title = "Discover"
        // Add padding so top of TVC not covered by nav bar title
        automaticallyAdjustsScrollViewInsets = true
        // Hide nav bar on swipe
        navigationController?.hidesBarsOnSwipe = true
        
        // Setup plain style TV
        tableViewSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewSetup() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Formatting
        tableView.backgroundColor = UIColor.white
        
        // Row height
        tableView.estimatedRowHeight = tableView.frame.width
    }
    
    // MARK: TableView Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellHeights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let maxWidth = tableView.frame.width
        let maxHeight = cellHeights[indexPath.row]
        let layout = UICollectionViewFlowLayout()

        print("row \(indexPath.row)")
        print("width\(maxWidth)")
        print("height\(maxHeight)")
        
        switch indexPath.row {
        // Matchups
        case 0:
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            // Sizing
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: maxWidth, height: maxHeight)
            
            // Configure collection view and add as child VC
            let matchupCVC = MatchupCollectionViewController(collectionViewLayout: layout)
            addChildViewController(matchupCVC)
            cell.contentView.addSubview(matchupCVC.view)
            matchupCVC.view.frame = cell.contentView.bounds
            matchupCVC.didMove(toParentViewController: self)
        
        // New
        case 1:
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            // Sizing
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            // CollageCVC implements FlowLayoutDelegate itemSize()
            
            // Configure collection veiw and add as child VC
            let collageCVC = CollageCollectionViewController(collectionViewLayout: layout)
            addChildViewController(collageCVC)
            cell.contentView.addSubview(collageCVC.view)
            collageCVC.view.frame = cell.contentView.bounds
            collageCVC.didMove(toParentViewController: self)
            
        default:
            break
        }
        
        return cell
    }

    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
}
