//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

// TODO: pause animation
// TODO: add table view dynamically so that we can have as many table view as categories
// TODO: preload

struct MatchupTableViewDataSource {
    var userName: String
    var image: UIImage
}

enum WinnerPost {
    case Left
    case Right
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
    var matchupCollectionView: UICollectionView?
    
    var leftColors = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.orange]
    var rightColors = [UIColor.orange, UIColor.cyan, UIColor.black, UIColor.blue, UIColor.red]
    
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
        matchupCollectionView = UICollectionView(frame: matchupContainerView.frame, collectionViewLayout: layout)
        guard let matchupCollectionView = matchupCollectionView else {
            print("failed to instantiate matchupCollectionView")
            return
        }
        matchupCollectionView.translatesAutoresizingMaskIntoConstraints = false
        matchupCollectionView.register(MatchupCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        matchupCollectionView.isPagingEnabled = true
        matchupCollectionView.backgroundColor = UIColor.green
        matchupCollectionView.allowsSelection = false
        matchupCollectionView.delegate = self
        matchupCollectionView.dataSource = self
        
        // Add constraint
        matchupContainerView.addSubview(matchupCollectionView)
        matchupContainerView.addConstraints([
            NSLayoutConstraint(
                item: matchupCollectionView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: matchupCollectionView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: matchupCollectionView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: matchupContainerView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1.0,
                constant: 0),
            NSLayoutConstraint(
                item: matchupCollectionView,
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
//
//        // Do any additional setup after loading the view.
//        
//        // Add buffer at top (by setting nav bar clear)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.view.backgroundColor = UIColor.clear
//        
//        //TODO: testing
//        loadImages()
//
//    }
//    
    
    var leftPost: Post?
    var rightPost: Post?
    var matchup: VoteBooth.Matchup?
    
    func loadImages(leftImageView: UIImageView?, rightImageView: UIImageView?) {
        guard let leftImageView = leftImageView, let rightImageView = rightImageView else {
            print("image view is nil")
            return
        }
        
        // Request matchup
        VoteBooth.serve { (matchup) in
            self.matchup = matchup
            // Get post IDs of matchup
            var IDs: [String] = []
            for post in matchup.posts {
                IDs.append(post.key)
            }

            FIRManager.shared.fetchPostsWithID(IDs, completion: { (snapshots) in
                self.leftPost = Post(snapshots[0])
                self.rightPost = Post(snapshots[1])
                
                guard let leftPost = self.leftPost, let rightPost = self.rightPost else {
                    print("post is nil")
                    return
                }
                
                // fetch image A
                FIRManager.shared.database.child(leftPost.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                    let image = Image(snapshot.value as! [String: AnyObject?])
                    
                    leftImageView.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)

                })

                // fetch image B
                FIRManager.shared.database.child(rightPost.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                    let image = Image(snapshot.value as! [String: AnyObject?])
                    
                    rightImageView.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)
                    
                })

                // TODO: test vote
                //VoteBooth.result(matchID: matchup.ID, winnerID: rightPost.postID!)
            })
        }
    }
    
    /** Uploads matchup result to server. Called from MatchupCollectionViewCell when image view is selected. */
    func uploadMatchupResult(winner: WinnerPost) {
        guard let leftPost = leftPost, let rightPost = rightPost, let matchup = matchup else {
            print("leftPost, rightPost or matchup is nil")
            return
        }
        
        var winnerPost: Post = leftPost
        if winner == WinnerPost.Right {
            winnerPost = rightPost
        }
        
        guard let winnerPostID = winnerPost.postID else {
            print("winnerPost.postID is nil")
            return
        }
        
        VoteBooth.result(matchID: matchup.ID, winnerID: winnerPostID)
        print("\(winner), post ID: \(winnerPostID), matchup ID: \(matchup.ID) is uploaded.")
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return leftColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MatchupCollectionViewCell else {
            print("Failed to instantiate matchup collection view cell")
            return UICollectionViewCell()
        }
        
        //        cell.leftImageView?.backgroundColor = leftColors[indexPath.item]
        //        cell.rightImageView?.backgroundColor = rightColors[indexPath.item]
        
        // Set cell's delegate to collection view so that cell can tell collection view to scroll
        // to the next cell when either of images is tapped
        cell.collectionViewDelegate = collectionView
        
        // HomeViewController.uploadMatchupResult() is called from MatchupCollectionViewCell when image is selected
        cell.homeViewControllerDelegate = self
        
        // set isVoted false because post has not been voted yet.
        cell.isVoted = false
        
        cell.leftLabel?.text = ""
        cell.rightLabel?.text = ""
        cell.leftLabel?.backgroundColor = UIColor.white
        cell.rightLabel?.backgroundColor = UIColor.white
        loadImages(leftImageView: cell.leftImageView, rightImageView: cell.rightImageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell size is the same as container view
        return CGSize(width: matchupContainerView.frame.width, height: matchupContainerView.frame.height)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let matchupCollectionView = matchupCollectionView else {
            print("matchup collection view is nil")
            return
        }
        let scrollViewContentWidth = matchupCollectionView.contentSize.width
        let scrollOffsetThreshold = scrollViewContentWidth - matchupCollectionView.bounds.size.width - 1000
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.x > scrollOffsetThreshold) {
            leftColors = leftColors + leftColors
            rightColors = rightColors + rightColors
            matchupCollectionView.reloadData()
        }
    }
}
