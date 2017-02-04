//
//  HomeViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // TODO testing
    @IBOutlet weak var imageone: UIImageView!
    @IBOutlet weak var imagetwo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add buffer at top (by setting nav bar clear)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        //TODO: testing
        loadImages()

    }
    
    func loadImages() {
        // Request matchup
        VoteBooth.serve { (matchup) in
            print("matchup ID: \(matchup.ID)")
            // Get post IDs of matchup
            var IDs: [String] = []
            for post in matchup.posts {
                IDs.append(post.key)
            }

            FIRManager.shared.fetchPostsWithID(IDs, completion: { (snapshots) in
                let postA = Post(snapshots[0])
                let postB = Post(snapshots[1])
                
                // fetch image A
                FIRManager.shared.database.child(postA.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                    let image = Image(snapshot.value as! [String: AnyObject?])
                    
                    self.imageone.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)

                })

                // fetch image B
                FIRManager.shared.database.child(postB.url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                    let image = Image(snapshot.value as! [String: AnyObject?])
                    
                    self.imagetwo.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)
                    
                })

                // TODO: test vote
                VoteBooth.result(matchID: matchup.ID, winnerID: postB.postID!)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
