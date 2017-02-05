//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    static let storyboardID = "Browser"
    static let viewControllerID = "CategoryTableViewController"
    
    // TODO testing

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var firstTableViewContainerView: UIView!
    @IBOutlet weak var secondTableViewContainerView: UIView!
    
    @IBOutlet weak var firstTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondTableViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let storyboard = UIStoryboard(name: HomeViewController.storyboardID, bundle: nil)
        guard let firstTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.viewControllerID) as? CategoryTableViewController,
            let secondTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.viewControllerID) as? CategoryTableViewController else {
                print("Failed to instantiate tvc")
                return
        }
        self.addChildViewController(firstTVC)
        self.addChildViewController(secondTVC)
        
        // CategoryTableViewController's viewDidLoad is called here
        firstTVC.view.layoutIfNeeded()
        secondTVC.view.layoutIfNeeded()
        
        // Get table view's height here and determine container's height
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


}
