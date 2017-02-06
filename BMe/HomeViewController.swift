//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

// TODO: Infinite scroll
// TODO: pause animation
// TODO: Fetch real data with FIRManager and display

struct MatchupTableViewDataSource {
    var userName: String
    var image: UIImage
}

class HomeViewController: UIViewController {

    static let storyboardID = "Browser"
    static let viewControllerID = "CategoryTableViewController"
    
    // TODO testing

    @IBOutlet weak var firstTableViewContainerView: UIView!
    @IBOutlet weak var secondTableViewContainerView: UIView!
    
    @IBOutlet weak var firstTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var matchupContainerView: UIView!
    
    let leftColors = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.orange]
    let rightColors = [UIColor.orange, UIColor.cyan, UIColor.black, UIColor.blue, UIColor.red]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        let storyboard = UIStoryboard(name: HomeViewController.storyboardID, bundle: nil)
        guard let firstTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.viewControllerID) as? CategoryTableViewController,
            let secondTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.viewControllerID) as? CategoryTableViewController else {
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
        print("firstTVC.tableView.frame.height: \(firstTVC.tableView.frame.height) in Home view controller")
        
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
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: matchupContainerView.frame.width, height: matchupContainerView.frame.width)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // Configure collection view
        let collectionView = UICollectionView(frame: matchupContainerView.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MatchupCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.green
        collectionView.allowsSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Add constraint
        matchupContainerView.addSubview(collectionView)
        matchupContainerView.addConstraints([
            NSLayoutConstraint(
                item: collectionView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: collectionView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: collectionView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: collectionView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1.0,
                constant: 0)
            ])
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        // Add buffer at top (by setting nav bar clear)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.view.backgroundColor = UIColor.clear
        
        //TODO: testing
//        loadImages()

//    }
    
//    func loadImages() {
//        // Request matchup
//        VoteBooth.serve { (matchup) in
//            print("matchup ID: \(matchup.ID)")
//            // Get post IDs of matchup
//            var IDs: [String] = []
//            for post in matchup.posts {
//                IDs.append(post.key)
//            }
//
//            FIRManager.shared.fetchPostsWithID(IDs, completion: { (snapshots) in
//                let postA = Post(snapshots[0])
//                let postB = Post(snapshots[1])
//                
//                // fetch image A
//                FIRManager.shared.database.child(postA.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
//                    let image = Image(snapshot.value as! [String: AnyObject?])
//                    
//                    self.imageone.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)
//
//                })
//
//                // fetch image B
//                FIRManager.shared.database.child(postB.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
//                    let image = Image(snapshot.value as! [String: AnyObject?])
//                    
//                    self.imagetwo.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)
//                    
//                })
//
//                // TODO: test vote
//                VoteBooth.result(matchID: matchup.ID, winnerID: postB.postID!)
//            })
//        }
//    }
//    
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return leftColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MatchupCollectionViewCell else {
            print("Failed to instantiate matchup collection view cell")
            return UICollectionViewCell()
        }
        
        // Set cell's delegate to collection view so that cell can tell collection view to scroll
        // to the next cell when either of images is tapped
        cell.delegate = collectionView
        cell.leftImageView?.backgroundColor = leftColors[indexPath.item]
        cell.rightImageView?.backgroundColor = rightColors[indexPath.item]
        cell.leftLabel?.text = ""
        cell.rightLabel?.text = ""
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell size is the same as container view
        return CGSize(width: matchupContainerView.frame.width, height: matchupContainerView.frame.height)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        <#code#>
    }
}
