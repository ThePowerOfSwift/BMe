//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/15/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

private struct HomeViewCellContent {
    var title: String
    var height: CGFloat
}

private let navBarTitle = "Discover"

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // Properties
    /** Model */
    private var contents: [HomeViewCellContent] {
        get {
            return [HomeViewCellContent(title: "Matchups", height: tableView.frame.width),
                    HomeViewCellContent(title: "New", height: tableView.frame.width)
            ]
        }
    }

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure top (Nav Bar and TVC behaviour)
        title = navBarTitle
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
//        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    // MARK: TableView Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let maxWidth = tableView.frame.width
        let maxHeight = maxWidth

        var vc = UIViewController()
        
        // Configure the layouts and view controllers
        switch indexPath.section {
        case 0: // Matchups
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            // Sizing
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.itemSize = CGSize(width: maxWidth, height: maxHeight)
            
            vc = MatchupCollectionViewController(collectionViewLayout: layout)
            
        case 1: // New
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            // Sizing: CollageCVC implements FlowLayoutDelegate
            
            vc = CollageCollectionViewController(collectionViewLayout: layout)
            
        default:
            break
        }
        
        addChildViewController(vc)
        cell.contentView.addSubview(vc.view)
        vc.view.frame = cell.contentView.bounds
        vc.didMove(toParentViewController: self)

        return cell
    }

    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = contents[indexPath.section]
        return content.height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let content = contents[section]
        return content.title

    }
}
