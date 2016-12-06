//
//  VideoComposition.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/17/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoComposition: AVPlayerItem{

// MARK: - Variables
    var name: String?
    var templateID: String?
    var gsAudioURL: String?
    var gsVideoURLs: String?
    
    // Video AVAssets
    private var _videoURLs: [URL] = []
    private var _audioURL: URL?
    
    // Readonly
    var audioURL: URL? {
        get {
            return _audioURL
        }
    }
    var videoURLs: [URL] {
        get {
            return _videoURLs
        }
    }
    var playerViewController: AVPlayerViewController {
        get {
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(playerItem: self)
            return vc
        }
    }
    var dictionaryFormat: [String: AnyObject?] {
        get {
            // construct array for 
            var urls: [String] = []
            
            var string: String
            for url in videoURLs {
                string = url.absoluteString
                urls.append(string)
            }
            
            let data = [Key.audioURL: audioURL?.absoluteString as AnyObject,
                        Key.gsAudioURL: gsAudioURL as AnyObject,
                        Key.videoURLs: urls as AnyObject,
                        Key.gsVideoURLs: gsVideoURLs as AnyObject,
                        Key.name: name as AnyObject,
                        Key.templateID: templateID as AnyObject]
            
            return data
        }
    }

    struct Key {
        static let videoURLs = "videosURLs"
        static let gsVideoURLs = "gsVideoURLs"
        static let audioURL = "audioURL"
        static let gsAudioURL = "gsAudioURL"
        static let name = "name"
        static let templateID = "id"
    }
    
    // TODO: -  Should move to Constants
    struct StoryboardKey {
        static let ID = "VideoComposer"
        static let videoComposerViewController = "VideoComposerViewController"
        static let metaViewController = "MetaViewController"
        static let mediaSelectorViewController = "MediaSelectorViewController"
        static let mediaSelectorNavigationController = "MediaSelectorNavigationController"
        static let mediaPickerViewController = "SongPickerViewController"
    }

    
// MARK: - Initializers
    
    // Initalize as AVPlayerItem that composes videos and sound together
    init(videoURLs: [URL], audioURL: URL?, name: String?, templateID: String?) {
        // Initialize
        _videoURLs = videoURLs
        _audioURL = audioURL
        
        let videoAVURLs = VideoComposition.getAVURLAssets(urls: videoURLs)
      
        var audioAVURL: AVURLAsset?
        if let audioURL = audioURL {
            audioAVURL = AVURLAsset(url: audioURL)
        }
        
        let info = VideoComposition.setup(videoURLs: videoAVURLs, audioURL: audioAVURL)
        super.init(asset: info.mixComposition, automaticallyLoadedAssetKeys: nil)
        self.videoComposition = info.avVideoComposition
        
        self.name = name
        self.templateID = templateID
    }
   
    // Initializer for JSON object (dictionary)
    // Assumes dictionary key, object structure:
    // VideoComposition.Key.videoURLs = [String]
    // VideoComposition.Key.audioURL = String
    convenience init (dictionary: [String: AnyObject?]) {
        var videoURLs: [URL] = []
        var audioURL: URL?
        
        // process video urls
        if let videoStrings = dictionary[VideoComposition.Key.videoURLs] as? NSArray {
            for string in videoStrings {
                if let videoURL = URL(string: string as! String) {
                    videoURLs.append(videoURL)
                }
            }
        }
        // process audio url
        if let audioURLString = dictionary[VideoComposition.Key.audioURL] as? String {
            audioURL = URL(string: audioURLString)
        }
        
        self.init(videoURLs: videoURLs,
                  audioURL: audioURL,
                  name: dictionary[VideoComposition.Key.name] as? String,
                  templateID: dictionary[VideoComposition.Key.templateID] as? String)
    }

    
// MARK: - Methods
    
    func thumbnails() -> [UIImage] {
        var images: [UIImage] = []
        let videosAVURLs = VideoComposition.getAVURLAssets(urls: videoURLs)
        
        for videoAVURL in videosAVURLs {
            if let image = VideoComposition.thumbnail(asset: videoAVURL) { images.append(image) }
        }
        
        return images
    }
    
    func render(fileNamed: String, completion: @escaping(_ session: AVAssetExportSession)->()) {
        // Create Exporter and set it to video export
        guard let exporter = AVAssetExportSession(asset: asset, presetName: Constants.ImageCompressionAndResizingRate.avExportQualityPreset) else { return }
        exporter.outputURL = AppDelegate.urlForNewDocumentFile(named: fileNamed)
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition
        
        // Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                completion(exporter)
            }
        }
    }
    
    
    
// MARK: - Private Methods
    
    
// MARK: - Class methods
    
    // Takes videos and audio and creates compositions to make a new AVPlayerItem
    // mixComposition contains the assets and instructions
    // avVideoComposition contains the video render instructions
    // TrackID 0 is the sound
    // TrackID 1+ are the videos
    class func setup(videoURLs: [AVURLAsset], audioURL: AVURLAsset?) -> (mixComposition: AVMutableComposition, avVideoComposition: AVMutableVideoComposition) {
        // Add each asset as a track to overall composition
        let mixComposition = AVMutableComposition()
        var videoInstructions: [AVMutableVideoCompositionLayerInstruction] = []

        // Track track begin time & ID
        var beginTime = kCMTimeZero
        
        // For each asset
        for i in 0..<videoURLs.count {
            autoreleasepool {
            let asset = videoURLs[i]
            
            // TODO: - delete:
            print("Processing video at url: \(asset.url.absoluteString)")
            print("\(asset.availableMediaCharacteristicsWithMediaSelectionOptions)")
            
            let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
            // Add a track to the composition
            let track = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(exactly: i + 1)!)
            do {
                // TODO - assumes there's only one track in the asset
                try track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: assetTrack, at: beginTime)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            beginTime = CMTimeAdd(beginTime, asset.duration)

            // Create instructions for each track
            let trackInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
            
            // Transform all to "Portrait" ("up" or 90 degrees)
            var assetTrackTransform = assetTrack.preferredTransform
            
            switch assetTrackTransform.orientation() {
            case .landscapeRight:
                // Rotate right 90 degrees
                assetTrackTransform = CGAffineTransform(translationX: assetTrack.naturalSize.height, y: 0.0)
                assetTrackTransform = assetTrackTransform.rotated(by: CGFloat(M_PI) / CGFloat(2.0))
            case .portrait:
                // Maintain original transform to portrait
                break
            case .landscapeLeft:
                // Rotate right 270 degrees
                assetTrackTransform = CGAffineTransform(translationX: 0.0, y: assetTrack.naturalSize.width)
                assetTrackTransform = assetTrackTransform.rotated(by: CGFloat(3.0 * M_PI) / CGFloat(2.0))
            case .portraitUpsideDown: // Orientation: upside down
                // Maintain original transform to upside down
                break
            case .unknown:
                // Maintain original transform
                break
            }

            trackInstruction.setTransform(assetTrackTransform, at: kCMTimeZero)
            
            // Fade out track so the following is shown
            trackInstruction.setOpacity(0.0, at: beginTime)
            videoInstructions.append(trackInstruction)
            }
        }

        // Create video composition instructions
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, beginTime)
        mainInstruction.layerInstructions = videoInstructions
        
        // Enable video composition,
        // And supply the instructions for video composition.
        let avVideoComposition = AVMutableVideoComposition()
        avVideoComposition.instructions = [mainInstruction]
        // Sample 1st video asset for settings

        if videoURLs.count > 0 {
            let assetTrack = videoURLs[0].tracks(withMediaType: AVMediaTypeVideo)[0]
            // FPS
            avVideoComposition.frameDuration = CMTimeMake(1, Int32(assetTrack.nominalFrameRate))
            // Render size to portrait only
            avVideoComposition.renderSize = CGSize(width: assetTrack.naturalSize.height, height: assetTrack.naturalSize.width)
        }
        
        // Attach audio
        if let audioURL = audioURL {
            let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, beginTime),
                                               of: audioURL.tracks(withMediaType: AVMediaTypeAudio)[0],
                                               at: kCMTimeZero)
            } catch {
                print("Error- Failed to load Audio track: \(error.localizedDescription)")
            }
        }
        
        return (mixComposition, avVideoComposition)
    }

    class func thumbnail(asset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image
        }
        catch {
            print("Error generating image for video")
        }
        
        return nil
    }
    
    class func thumbnail(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        return VideoComposition.thumbnail(asset: asset)
    }
    
    class func getAVURLAssets(urls: [URL]) -> [AVURLAsset] {
        var urlAssets: [AVURLAsset] = []
        
        for url in urls {
            urlAssets.append(AVURLAsset(url: url))
        }
        
        return urlAssets
    }
}

