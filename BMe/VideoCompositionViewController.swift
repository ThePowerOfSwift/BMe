//
//  VideoCompositionViewController.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/19/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCompositionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Models
    var videoComposition: VideoComposition? {
        didSet {
            setup()
        }
    }
    
    private var thumbnails: [UIImage]?
    private var videoURLs: [URL]?
    private var audioURL: URL?

    // MARK: - Variables
    
    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
    }
    
    func setup() {
        if let videoComposition = videoComposition {
            thumbnails = videoComposition.thumbnails()
            videoURLs = videoComposition.videoURLs
            audioURL = videoComposition.audioURL!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Methods
    
    func updateRow(_ row: Int, url: URL) {
        videoURLs?[row] = url
        
        if let thumbnail = VideoComposition.thumbnail(url: url) {
            thumbnails?[row] = thumbnail
        }
        
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let videoComposition = videoComposition {
            return videoComposition.videoURLs.count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCompositionCollectionViewCell", for: indexPath) as! VideoCompositionCollectionViewCell
        
        if let videoURLs = videoURLs,
            let thumbnails = thumbnails {
            cell.imageView.image = thumbnails[indexPath.row]
            cell.url = videoURLs[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
