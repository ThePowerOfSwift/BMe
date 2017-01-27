//
//  FeaturedViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/8/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseDatabase

class FeaturedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var hookButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var videoBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // Format ALLCAPS
    @IBOutlet weak var restaurantNameLabel: UILabel!
    // Format CUISINE | AREA | COST RATING ($$$$)
    @IBOutlet weak var restaurantDetailLabel: UILabel!
    @IBOutlet weak var foodRatingLabel: UILabel!
    @IBOutlet weak var decorRatingLabel: UILabel!
    @IBOutlet weak var serviceRatingLabel: UILabel!
    
    // Video player objects
    let playerVC = AVPlayerViewController()
    let player = AVPlayer()

    // Model
    var ref = FIRManager.shared.database.child("review").queryOrdered(byChild: "timestamp")
    var review: FIRDataSnapshot!
    var _refHandle: FIRDatabaseHandle?
    var reviewDescription: String?
    var imageGSurl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add buffer at top (by setting nav bar clear)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
        // Setup video replay
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        player.isMuted = false
        playerVC.player = player
        playerVC.videoGravity = AVLayerVideoGravityResizeAspectFill
        // Add video as child vc
        addChildViewController(playerVC)
        playerVC.view.frame = videoBackgroundView.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoBackgroundView.addSubview(playerVC.view)
        playerVC.didMove(toParentViewController: self)
        
        playerVC.showsPlaybackControls = false
        
        // setup tv
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.backgroundView?.isUserInteractionEnabled = false
        tableView.contentInset = UIEdgeInsets(top: videoBackgroundView.frame.height, left: 0, bottom: 0, right: 0)
        loadDatasource()
    }
    
    deinit {
        ref.removeObserver(withHandle: _refHandle!)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadDatasource(){
        _refHandle = ref.observe(.childAdded, with: { (snapshot) in
            self.review = snapshot
            self.showReview()
            self.showUser()
            self.loadVideo()
        })
    }
    
    func showUser() {
        //TODO: - add user avatar and profile
    }
    
    func showReview() {
        if self.review.hasChildren() {
            let data = self.review.dictionary
            
            restaurantNameLabel.text = data["restaurantname"] as? String
            restaurantNameLabel.text = restaurantNameLabel.text?.uppercased()
            
            // Format CUISINE | AREA | COST RATING ($$$$)
            if let cuisine = data["cuisine"] as? String,
                let neighbourhood = data["neighbourhood"] as? String,
                let costRating = data["costRating"] as? String {
                
                restaurantDetailLabel.text = "\(cuisine) • \(neighbourhood) • \(costRating)"
                restaurantDetailLabel.text = restaurantDetailLabel.text?.uppercased()
            }
            
            foodRatingLabel.text = data["foodRating"] as? String
            decorRatingLabel.text = data["decorRating"] as? String
            serviceRatingLabel.text = data["serviceRating"] as? String
            reviewDescription = data["review"] as? String
        }
        tableView.reloadData()
    }
    
    func loadVideo() {
        if self.review.hasChildren() {
            let data = self.review.dictionary
            
            // Load video
            let videoURL = URL(string: data["videoURL"] as! String)
            // Make Video Json object and grab url to display video
            FIRManager.shared.database.child(videoURL!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                let video = Video(snapshot.dictionary)
                let playerItem = AVPlayerItem(url: video.downloadURL!)

                
                //test low res vid
//                let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/b-me-e21b7.appspot.com/o/video%2FRDzlOBwQ2hSwkcu0bJSH39PzQmD3%2F502770920525.mov?alt=media&token=e493719c-5ead-4671-9282-07e226f5bbf9")!
//                let playerItem = AVPlayerItem(url: url)
                
                self.player.replaceCurrentItem(with: playerItem)
                self.player.automaticallyWaitsToMinimizeStalling = true
                self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

                // Setup player end for loop observation
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            })
            
            // Load image
            let imageURL = URL(string: data["imageURL"] as! String)
            // Make image Json object and grab url to display video
            FIRManager.shared.database.child(imageURL!.path).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    let image = Image(snapshot.dictionary)
                    self.imageGSurl = image.gsURL
                    print("db child: \(imageURL)")
                    print("gsurl \(image.gsURL))")
            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if ((object as! AVPlayer) == self.player) && (keyPath == "status") {
            if self.player.status == AVPlayerStatus.readyToPlay {
                self.player.play()
                //MARK: - TODO max player vc and autoplay
            } else if self.player.status == AVPlayerStatus.failed {
                
            }
        }
    }
    
    func playerItemDidReachEnd(_ notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
        player.isMuted = true
    }
    
    // MARK: - TV Delegate methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - TV Datasource methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeaturedTableViewCell", for: indexPath) as! FeaturedTableViewCell
        cell.isUserInteractionEnabled = false

        // Review cell
        if (indexPath.row == 0) {
            if let reviewDescription = reviewDescription {
                cell.contentImageView.isHidden = true
                
                cell.contentLabel.text = reviewDescription
            }
        }
        // Image cell
        else if (indexPath.row == 1) {
            if let imageGSurl = imageGSurl {
                cell.contentLabel.isHidden = true
                
                cell.contentImageView.contentMode = .scaleAspectFill
                cell.contentImageView.loadImageFromGS(url: imageGSurl, placeholderImage: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Review & image + video
        return 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
