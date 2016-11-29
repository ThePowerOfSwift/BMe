//
//  MediaSelectorViewController.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/19/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import AVKit

class MediaSelectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

// MARK: - Outlets
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        next()
    }
    
    
// MARK: - Variables
    // Model
    var data: [String: AnyObject?]!
    private var composition: VideoComposition?
    
    // Media browsers
    var playerVC = AVPlayerViewController()
    let imgManager = PHCachingImageManager.default()
    
    
    // Models
//    private var audioURL: URL!
    private var phAssets: PHFetchResult<PHAsset>!
    private var assetsSelected = 0 {
        didSet {
            if assetsSelected > 0 {
                nextButton.isEnabled = true
            }
            else { nextButton.isEnabled = false }
        }
    }
    
    // Constants
    struct Layout {
        static let itemSpacing: CGFloat = 1.00
        static let thumbnailSize: CGSize = CGSize(width: 93.00, height: 93.00)
    }
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        assetsSelected = 0
        
        // CollectionView setup
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        // Initialize VideoComposition in backgroun
        DispatchQueue.global(qos: .background).async {
//            self.composition = VideoComposition(dictionary: self.data)
//            self.audioURL = self.composition?.audioURL!
            DispatchQueue.main.async {
//                self.collectionView.reloadData()
            }
        }
        
        // Get assets from album
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        phAssets = PHAsset.fetchAssets(with: options)
        
        // Setup banner media browsers
        imageView.isHidden = true
        playerVC.player = AVPlayer()
        playerVC.player?.isMuted = true
        playerVC.videoGravity = AVLayerVideoGravityResizeAspectFill
        
            // Add PlayerVC to banner
        addChildViewController(playerVC)
        playerVC.view.frame = bannerView.bounds
        playerVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        bannerView.addSubview(playerVC.view)
        playerVC.didMove(toParentViewController: self)
        playerVC.view.isHidden = true
        
        // Select first item
        if phAssets.count > 0 {
            changeBanner(for: phAssets[0])
        }
        
        // Enable CollectionView scroll on entire VC
        view.addGestureRecognizer(collectionView.panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Banner View  methods

    func changeBanner(for asset: PHAsset) {
        // Detect media type
        if asset.mediaType == .image {
            playerVC.view.isHidden = true
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            imgManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: {
                (image: UIImage?, info: [AnyHashable : Any]?) in
                DispatchQueue.main.async {
                    self.imageView.contentMode = .scaleAspectFill
                    self.imageView.image = image
                    self.imageView.isHidden = false
                }
            })
        
        } else if asset.mediaType == .video {
            imageView.isHidden = true
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            imgManager.requestPlayerItem(forVideo: asset, options: options, resultHandler: { (playerItem: AVPlayerItem?, info: [AnyHashable : Any]?) in
                DispatchQueue.main.async {
                    self.playerVC.player?.replaceCurrentItem(with: playerItem)
                    self.playerVC.view.isHidden = false
                    self.playerVC.player?.play()
                }
            })
        }
    }

// MARK: - Gesture methods
    
    
// MARK: - CollectionView Delegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssets.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaSelectorCollectionViewCell", for: indexPath) as! MediaSelectorCollectionViewCell
        cell.tag = indexPath.row

        let asset = phAssets[indexPath.item ]
        
        
        imgManager.requestImage(for: asset, targetSize: Layout.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
            if cell.tag == indexPath.row {
                cell.image = image
                cell.isVideo = (asset.mediaType == .video)
            }
            })
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeBanner(for: phAssets[indexPath.row])
        assetsSelected += 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        assetsSelected -= 1
    }
    
// MARK: - CollectionView FlowLayout Delegate Methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Layout.thumbnailSize
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.itemSpacing
    }
    
// MARK: - Methods
    func next() {
        // Get selected paths
        let indexPaths: [IndexPath] = collectionView.indexPathsForSelectedItems!
        
        var assetIdentifiers: [String] = []
        for path in indexPaths {
            let asset = phAssets[path.row]
            assetIdentifiers.append(asset.localIdentifier)
            print(path.row)
        }
        
        let selectedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
    }
    
    /*
    func renderComposition() {
        
        // render timing?
        // split up the times automatically? (take the natural length of videos)?
        // use pre marked split?
        // include pictures
        
        // TODO: - get meta for video
        let restaurant = "get restaurant"
        let name = "name"
        if let composition = composition {
            VideoComposition(videoURLs: videoURLs, audioURL: audioURL, name: name, templateID: composition.templateID).render(fileNamed: "render_temp.mov", completion: {
            (session: AVAssetExportSession) in
            print("Success: rendered video")
            
            // Convert rendered to upload video with using updated links
            let video = Video(userId: AppState.shared.currentUser?.uid,
            username: AppState.shared.currentUser?.displayName,
            templateId: self.data[VideoComposition.Key.templateID] as? String,
            videoURL: session.outputURL?.absoluteString,
            gsURL: "",
            createdAt: Date(),
            restaurantName: restaurant)
            
            FIRManager.shared.uploadVideo(video: video, completion: { })
        })
        }
    }
 */
}
