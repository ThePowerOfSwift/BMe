//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

// TODO: preload array of a pair of posts (maybe fetch 5 posts at a time)
// TODO: add table view dynamically so that we can have as many table view as categories

struct MatchupTableViewDataSource {
    var userName: String
    var image: UIImage
}

enum WinnerPost {
    case Left
    case Right
}

class HomeViewController_old: UIViewController {
    
    static let viewControllerID = "CategoryTableViewController"
    
    // TODO testing
    
    @IBOutlet weak var firstTableViewContainerView: UIView!
    @IBOutlet weak var secondTableViewContainerView: UIView!
    
    @IBOutlet weak var firstTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var matchupContainerView: UIView!
    var matchupCVC: UICollectionViewController?
    
    @IBOutlet weak var baseScrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Discover"

        print("view size: \(view.bounds.size)")
        // Calculate size for first container "Matchup
        
        print("matchup container: \(matchupContainerView.frame.size)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let storyboard = UIStoryboard(name: Constants.SegueID.Storyboard.Home, bundle: nil)
        guard let firstTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController_old.viewControllerID) as? CategoryTableViewController,
            let secondTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController_old.viewControllerID) as? CategoryTableViewController else {
                print("Failed to instantiate tvc")
                return
        }
        self.addChildViewController(firstTVC)
        self.addChildViewController(secondTVC)
        
        // Assign data source
        firstTVC.matchupTableViewDataSource = trendingMatchupTableViewDataSource
        firstTVC.matchupTitle = "Trending"
        secondTVC.matchupTableViewDataSource = discoverMatchupTableViewDataSource
        secondTVC.matchupTitle = "Discover"
        
        // CategoryTableViewController's viewDidLoad is called here
        firstTVC.view.layoutIfNeeded()
        secondTVC.view.layoutIfNeeded()
        
        // After CategoryTableViewController's viewDidLoad is called,
        // you can get tableView's frame that has been configured there
        // to set the container size of tableView
        firstTableViewHeightConstraint.constant = firstTVC.tableView.frame.height
        secondTableViewHeightConstraint.constant = secondTVC.tableView.frame.height
        view.layoutIfNeeded()
        
        guard let firstTableView = firstTVC.tableView, let secondTableView = secondTVC.tableView else {
            print("Failed to instantiate tableView")
            return
        }
        firstTableViewContainerView.addSubview(firstTableView)
        secondTableViewContainerView.addSubview(secondTableView)
        
        setupMatchupCollectionView()
    }
    
    func setupMatchupCollectionView() {
        // Configure layout
        let maxWidth = matchupContainerView.frame.width
        let maxHeight = matchupContainerView.frame.width
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // Sizing
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: maxWidth, height: maxHeight)
        
        // Configure collection view and add as child VC
        matchupCVC = MatchupCollectionViewController(collectionViewLayout: layout)
        self.addChildViewController(matchupCVC!)
        matchupContainerView.addSubview(matchupCVC!.view)
        matchupCVC!.view.frame = matchupContainerView.frame
        matchupCVC!.didMove(toParentViewController: self)
    }
    
    let trendingMatchupTableViewDataSource: [MatchupTableViewDataSource] =
        [MatchupTableViewDataSource(userName: "a1", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "a2", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "3", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "4", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!),
         MatchupTableViewDataSource(userName: "AAAA", image: UIImage(named: "chinatown.jpg")!)]
    
    let discoverMatchupTableViewDataSource: [MatchupTableViewDataSource] =
        [MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!),
         MatchupTableViewDataSource(userName: "BBBB", image: UIImage(named: "golden_gate_bridge.jpg")!)]
}


