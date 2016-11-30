//
//  CompositionTestViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/24/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import MediaPlayer

class CompositionTestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var action = ""
    var videoURLs: [URL] = []
    var audioURL: URL?
    
    @IBAction func didTapUploadVideo(_ sender: Any) {
        action = "Upload video"
        presentImagePicker(delegate: self, completion: nil)
    }
    
    @IBAction func didTapPickSound(_ sender: Any) {
        action = "Pick sound"
        let mPicker = MPMediaPickerController(mediaTypes: .any)
        mPicker.delegate = self
        mPicker.allowsPickingMultipleItems = false
        
        present(mPicker, animated: true, completion: nil)
    }
    
    @IBAction func didTapTestTemplate(_ sender: Any) {
        let composition = VideoComposition(videoURLs: videoURLs, audioURL: audioURL, name: "run template", templateID: "n/a")
        present(composition.playerViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapPickVideo(_ sender: Any) {
        action = "Pick video"
        presentImagePicker(delegate: self, completion: nil)
    }
    
    @IBAction func didTapUploadTemplate(_ sender: Any) {
        activityIndicator.startAnimating()
        
        let composition = VideoComposition(videoURLs: videoURLs, audioURL: audioURL, name: "test", templateID: "test")
        
        FIRManager.shared.uploadVideoComposition(composition: composition, completion: {
            self.activityIndicator.stopAnimating()
        })
        audioURL = nil
        videoURLs = []
        uploadTemplate.isEnabled = enableTemplateUpload()
        
        action = ""
    }
    
    @IBAction func didTapeWatchVideo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "VideosListVC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VideosListVC")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapWatchTemplate(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TemplateListVC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TemplateListVC")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func enableTemplateUpload() -> Bool {
        if audioURL != nil && videoURLs.count > 0 {
            return true
        }
        return false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        if (mediaType == kUTTypeMovie) {
            if action == "Upload video" {
                let url = info[UIImagePickerControllerMediaURL] as? URL
                print("Picked asset at url: \(url)")
                let video = Video(userId: AppState.shared.currentUser?.uid,
                                  username: AppState.shared.currentUser?.displayName,
                                  templateId: "",
                                  videoURL: url!.absoluteString,
                                  gsURL: "",
                                  createdAt: Date(),
                                  restaurantName: "")
                activityIndicator.startAnimating()
                FIRManager.shared.uploadVideo(video: video, completion: {
                self.activityIndicator.stopAnimating()
                })
            }
            else if action == "Pick video" {
                let url = info[UIImagePickerControllerMediaURL] as? URL
                print("Picked asset at url: \(url)")
                videoURLs.append(url!)
                uploadTemplate.isEnabled = enableTemplateUpload()
            }
        }
// DOES NOT ACCEPT IMAGES
        else if (mediaType == kUTTypeImage) {
            // assets-library://asset/asset.PNG?
            // let url = info[UIImagePickerControllerReferenceURL] as? URL
        }
        
        action = ""
        dismiss(animated: true, completion: nil)
    }
    
    // When a song is picked
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true) {
            let song = mediaItemCollection.items[0]
            let songURL = song[MPMediaItemPropertyAssetURL] as! URL
            
            if self.action == "Pick sound" {
                // Transform URL to local
                let assetURL = AppDelegate.urlForNewDocumentFile(named: "temp.m4a")
                AVURLAsset(url: songURL).exportIPodAudio(url: assetURL, completion: {
                    self.audioURL = assetURL
                })
                self.uploadTemplate.isEnabled = self.enableTemplateUpload()
            }
        }
    }
    
    @IBOutlet weak var uploadTemplate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        uploadTemplate.isEnabled = false
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
