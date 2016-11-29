//
//  VideoComposerViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Photos

class VideoComposerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MetaViewControllerDelegate {

    //MARK: - Outlets
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Models
    var phAssets: [PHAsset]!
    private var audioURL: URL!
    private var videoURLs: [URL?] = []
    
    var composition: VideoComposition!
    
    let imgManager = PHCachingImageManager.default()
    
    private let kSegueID = "pushToMeta"
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.backgroundColor = UIColor.gray
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addGestureRecognizer(collectionView.panGestureRecognizer)
        
        // Setup video composition
        prepareURLs { 
            self.loadComposition()
        }
        
        // Prepare navigation bar
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped(_:)))
        navigationItem.rightBarButtonItem = nextButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Navigation  methods

    func nextButtonTapped(_ sender: UIBarButtonItem) {
        next()
    }
    
    func next() {
        let storyboard = UIStoryboard(name: VideoComposition.StoryboardKey.ID, bundle: nil)
        let metaVC = storyboard.instantiateViewController(withIdentifier: VideoComposition.StoryboardKey.metaViewController) as! MetaViewController
        metaVC.delegate = self
        present(metaVC, animated: true, completion: nil)
    }
    
    
    //MARK: - CollectionView Datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoComposerCollectionViewCell", for: indexPath)
        cell.tag = indexPath.row
        
        let asset = phAssets[indexPath.row]
        let mediaType = asset.mediaType
        let displayRect = CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.Layout.inspectionSize)
        if mediaType == .image {
            // Get the Image
            imgManager.requestImage(for: asset, targetSize: Constants.Layout.inspectionSize, contentMode: .aspectFill, options: nil, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                DispatchQueue.main.async {
                    if cell.tag == indexPath.row {
                        let imageView = UIImageView(frame: displayRect)
                        imageView.image = image
                        imageView.contentMode = .scaleAspectFill
                        cell.contentView.addSubview(imageView)
                    }
                }
            })

        } else if mediaType == .video {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            imgManager.requestPlayerItem(forVideo: asset, options: options, resultHandler: { (playerItem: AVPlayerItem?, info: [AnyHashable : Any]?) in
                DispatchQueue.main.async {
                    if cell.tag == indexPath.row {
                        let player = AVPlayer(playerItem: playerItem)
                        
                        let playerLayer = AVPlayerLayer(player: player)
                        playerLayer.frame = displayRect
                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        cell.contentView.layer.addSublayer(playerLayer)
                        player.play()
                        player.isMuted = true
                    }
                }
            })
        }
        
        return cell
    }
    
    // MARK: - CollectionView FlowLayout Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.Layout.inspectionSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
    // MARK: - Model Methods
    
    func prepareURLs(_ completion: (()->())?) {
        //placeholder audio
        let tempAudio = URL(string: "https://firebasestorage.googleapis.com/v0/b/b-me-e21b7.appspot.com/o/audio%2FDuwrIKqnWOXa8muRw7rPx7tcb1k1%2F501836136190.m4a?alt=media&token=171ea997-34ad-4704-bc03-d057cd22124d")
        audioURL = tempAudio
        
        var processedCount = 0
        for i in 0..<phAssets.count {
            let index = i
            videoURLs.append(nil)
            
            let asset = phAssets[index]
            let mediaType = asset.mediaType
            
            if mediaType == .image {
                let options = PHContentEditingInputRequestOptions()
                options.isNetworkAccessAllowed = true
                asset.requestContentEditingInput(with: options, completionHandler: { (content: PHContentEditingInput?, info:[AnyHashable : Any]) in
                    self.videoURLs[index] = content?.fullSizeImageURL
                    
                    processedCount += 1
                    if processedCount == self.phAssets.count,
                        let completion = completion {
                        completion()
                    }
                })
            } else if mediaType == .video {
                // Get video/image URLs
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                imgManager.requestAVAsset(forVideo: phAssets[index], options: options, resultHandler: {
                    (asset: AVAsset?, audio: AVAudioMix?, info: [AnyHashable : Any]?) in
                    let urlAsset = asset as! AVURLAsset
                    self.videoURLs[index] = urlAsset.url
                    
                    processedCount += 1
                    if processedCount == self.phAssets.count,
                        let completion = completion {
                        completion()
                    }
                })
            }
        }
    }
    
    func loadComposition() {
        composition = VideoComposition(videoURLs: videoURLs as! [URL], audioURL: audioURL, name: "", templateID: "")
        print("composition loaded")
        
        DispatchQueue.main.async {
            let vc = self.composition.playerViewController
            self.addChildViewController(vc)
            vc.view.frame = self.bannerView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.bannerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    // MARK: - MetaDelegate Methods

    func post(meta: [String : String]) {
//        let name = meta[MetaViewController.Key.name]
        let restaurant = meta[MetaViewController.Key.restaurant]

         // render timing?
         // split up the times automatically? (take the natural length of videos)?
         // use pre marked split?
         // include pictures
        
         composition.render(fileNamed: "render_temp.mov", completion: {
         (session: AVAssetExportSession) in
         print("Success: rendered video")
         
         // Convert rendered to upload video with using updated links
         let video = Video(userId: AppState.shared.currentUser?.uid,
         username: AppState.shared.currentUser?.displayName,
         templateId: "",
         videoURL: session.outputURL?.absoluteString,
         gsURL: "",
         createdAt: Date(),
         restaurantName: restaurant)
         
         FIRManager.shared.uploadVideo(video: video, completion: { })
         })
    }
}
