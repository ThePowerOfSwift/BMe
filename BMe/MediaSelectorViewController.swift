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
import MediaPlayer

class MediaSelectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MPMediaPickerControllerDelegate, UIScrollViewDelegate, LocationButtonDelegate {

// MARK: - Outlets
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var locationButton: LocationButton!
    
    @IBAction func nextButtonTapped(_ sender: NextButton!) {
        next()
    }
    
    @IBAction func musicButtonTapped(_ sender: Any) {
        present(songPicker, animated: true, completion: nil)
    }
    
// MARK: - Variables
    // Model
    private var selectedRows: [Int] = [] {
        didSet {
            if selectedRows.count > 0 {
                nextButton.isEnabled = true
            }
            else { nextButton.isEnabled = false }
        }
    }
    private var audioURL: URL?
    private var meta: [String: AnyObject?]?
    
    // Media browsers
    var playerVC = AVPlayerViewController()
    var bannerCurrentLoaded = -1
    let imgManager = PHCachingImageManager.default()
    let songPicker = MPMediaPickerController(mediaTypes: .anyAudio)

    // Models
    private var phAssets: PHFetchResult<PHAsset>!
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = true
        nextButton.isEnabled = false
        // Prevent empty header space at top of collection view
        automaticallyAdjustsScrollViewInsets = false
        
        // CollectionView setup
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        // Get assets from album
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        phAssets = PHAsset.fetchAssets(with: options)
        phAssets = PHAsset.fetchAssets(with: .video, options: options)
        
        // Setup banner
        bannerView.backgroundColor = Styles.Color.Primary
        // Setup banner media browsers
        imageView.isHidden = true
        playerVC.showsPlaybackControls = false
        playerVC.player = AVPlayer()
        playerVC.player?.isMuted = true
        playerVC.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Add PlayerVC to banner
        addChildViewController(playerVC)
        playerVC.view.frame = imageView.frame
        playerVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        bannerView.addSubview(playerVC.view)
        playerVC.didMove(toParentViewController: self)
        playerVC.view.isHidden = true
                
        // Song picker
        bannerView.bringSubview(toFront: musicButton)
        songPicker.delegate = self
        songPicker.showsItemsWithProtectedAssets = false
        
        locationButton.delegate = self
        
        // Select first item
        if phAssets.count > 0 {
            changeBanner(for: phAssets[0], index: 0)
        }
        
        // Enable CollectionView scroll on entire VC
        view.addGestureRecognizer(collectionView.panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Banner View  methods

    func changeBanner(for asset: PHAsset, index: Int) {
        if (index == bannerCurrentLoaded) { return }
        
        bannerCurrentLoaded = index
        
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

        imgManager.requestImage(for: asset, targetSize: Constants.Layout.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
            DispatchQueue.main.async {
                if cell.tag == indexPath.row {
                    cell.image = image
                    cell.isVideo = (asset.mediaType == .video)
                    
                    // Get duration for videos
                    if asset.mediaType == .video {
                        let options = PHVideoRequestOptions()
                        options.version = .current
                        self.imgManager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset: AVAsset?, avAudio: AVAudioMix?, info: [AnyHashable : Any]?) in
                            DispatchQueue.main.async {
                                cell.durationLabel.text = self.stringFromTimeInterval(interval: asset.duration)
                            }
                        })
                    }
                }
            }
        })
        return cell
    }
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        
//        let ms = Int((interval.truncatingRemainder(dividingBy: 1.0)) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
//        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
//        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeBanner(for: phAssets[indexPath.row], index: indexPath.row)
        selectedRows.append(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        for index in 0..<selectedRows.count {
            if selectedRows[index] == indexPath.row {
                selectedRows.remove(at: index)
                break
            }
        }
    }
    
// MARK: - CollectionView FlowLayout Delegate Methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.Layout.thumbnailSize
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.Layout.itemSpacing
    }
    
// MARK: - MPMediaPicker Delegate Methods
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: {
        })
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let song = mediaItemCollection.items[0]
        let songURL = song[MPMediaItemPropertyAssetURL] as! URL
        
        // Transform URL to local
        let assetURL = AppDelegate.urlForNewDocumentFile(named: "temp.m4a")
        AVURLAsset(url: songURL).exportIPodAudio(url: assetURL, completion: { (url: URL) in
            self.audioURL = url
        })

        dismiss(animated: true) {
            let highlightedImage = UIImage(named: Constants.Images.audioYellow)
            self.musicButton.setImage(highlightedImage, for: UIControlState.normal)
        }
    }
// MARK: - Location Delegate methods
    func locationButton(yelpDidSelect restaurant: Restaurant) {
        meta = restaurant.dictionary
    }

    func locationButton(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> ())?) {
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
// MARK: - Methods
    /*  TESTING FOR TIMELAPSE BUILDER
    func next() {
        // Generate selected assets
        var selectedAssets: [PHAsset] = []
        for row in selectedRows {
            let asset = phAssets[row]
            selectedAssets.append(asset)
        }
        
        for phAsset in selectedAssets {
            //Take phassets that are images
            if phAsset.mediaType == .image {
                
                //Make them into videos
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.isSynchronous = true
                options.version = .current
                
                imgManager.requestImageData(for: phAsset, options: nil, resultHandler: { (data, string, orientation, info) in
                    let image = UIImage(data: data!)
                    
                    
                    // Take URL and convert to video
                    let newURL = AppDelegate.urlForNewDocumentFile(named: "temptestvid.mp4")
                    let videoBuilder = TimeLapseBuilder(image: image!, videoOutputURL: newURL)
                    videoBuilder.build(progress: { (progress: Progress) in
                        
                    }, completion: { (url: URL?, error: Error?) in
                        if let error = error {
                            print("There was an error making the jpeg video \(error.localizedDescription)")
                            return
                        }
                        
                        // Store result here

                        print("Opening video rendered to: \(url?.path)")
//                        FIRManager.shared.putObjectOnStorage(url: url!, contentType: .video, completion: { (metadata, error) in
                            let avplayer = AVPlayerViewController()
                            let player = AVPlayer(url: url!)
                        
                            avplayer.player = player
                            self.present(avplayer, animated: true, completion: {
                                avplayer.player?.play()
//                            })
                        })
                    })
                })
                
                break
            }
            
        }
    }*/

    func next() {
        print("next")
        let destination = UIStoryboard.init(name: Constants.SegueID.Storyboard.VideoComposer, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.VideoComposerViewController) as! VideoComposerViewController
        
        // Generate selected assets
        var selectedAssets: [PHAsset] = []
        for row in selectedRows {
            let asset = phAssets[row]
            selectedAssets.append(asset)
        }
        
        destination.phAssets = selectedAssets
        destination.audioURL = audioURL
        if let meta = meta {
            print("Attaching meta: \(meta)")
            destination.meta = meta
        }
        
        present(destination, animated: true, completion: nil)
    }

    
// MARK: - Scrollview delegate methods
    //Aspect Ratio: bannerViewAspectRatio.multiplier
//    var lastContentOffset: CGPoint?
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let lastContentOffset = lastContentOffset {
//            let delta = scrollView.contentOffset.y - lastContentOffset.y
//
//            if (lastContentOffset.y > scrollView.contentOffset.y) {
//                print("scrolling up \(delta)")
//            }
//            else if (lastContentOffset.y < scrollView.contentOffset.y) {
//                print("scrolling down \(delta)")
//            }
//        }
//        lastContentOffset = scrollView.contentOffset
//        
////        collectionViewTopConstraint.constant
//        
//    }
}
