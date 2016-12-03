//
//  FIRManager.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase



class FIRManager: NSObject {
    
    // Singleton
    static let shared = FIRManager()
    
    // Properties
    var database: FIRDatabaseReference {
        get{ return FIRDatabase.database().reference()
        }
    }
    var storageBucketURLString: String {
        get {
             return FIRApp.defaultApp()!.options.storageBucket
        }
    }
    // Reference to storage bucket
    var storage: FIRStorageReference {
        get {
            return FIRStorage.storage().reference(forURL: "gs://" + storageBucketURLString)
        }
    }
    // Returns a unique timestamp with the UID as parent folder
    var uniqueIdentifier: String {
        get {
            return "\((FIRAuth.auth()?.currentUser?.uid)!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
        }
    }

    private override init() {
        super.init()
    }

// MARK: - Methods
    func storage(url: String) -> FIRStorageReference {
        return FIRStorage.storage().reference(forURL: url)
    }
    
    // Listen for existing/new objects in the Firebase database
    func observeDatabaseObject(named: String, event: FIRDataEventType, completion:@escaping (FIRDataSnapshot)->()) -> FIRDatabaseHandle {
        // Listen for new messages in the Firebase database
        return database.child(named).observe(event, with: completion)
        //typical completion handler code:
        /*
         self.model.append(snapshot)
         self.tableView.insertRows(at: [IndexPath(row: self.videos.count-1, section: 0)], with: .automatic)
         */
    }
    
    // complement to observeDatabaseObject
    func unobserveDatabaseObject(named: String, handle: FIRDatabaseHandle) {
        database.child(named).removeObserver(withHandle: handle)
    }

    func putObjectOnStorage(data: Data, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        storage.addObject(data: data, contentType: contentType, completion: completion)
    }

    func putObjectOnStorage(url: URL, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        storage.addObject(url: url, contentType: contentType, completion: completion)
    }

    func putObjectOnDatabase(named: String, data: [String: AnyObject?], completion:@escaping (FIRDatabaseReference, Error?)->()) {
        database.addObject(named: named, data: data, completion: completion)
    }
    
    // Deprecated; use FIRStorageMetadata.gsURL
    func storageAbsoluteURL(_ metadata: FIRStorageMetadata) -> String {
        return storage.child(metadata.path!).description
    }
    
    func getVideos(completion: @escaping ([Video])->()) {
        
        let videoQuery = database.child(ContentType.video.objectKey()).queryOrdered(byChild: "CreatedAt").observe(.value, with: { snapshot in
            var videos = [Video]()
            for item in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let value = item.value as! [String:AnyObject?]
                let video = Video(dictionary: value)
                videos.append(video)
            }
            completion(videos)
        })
    }
    
    func uploadVideo(video: Video, completion: (()->())?) {
        putObjectOnStorage(url: URL(string: video.videoURL!)!, contentType: .video, completion: {
            (metadata: FIRStorageMetadata?, error: Error?) in
            
            if error != nil {
                print("Error- abort putting video")
                return
            }

            // Update data dictionary to be put on Firebase Database
            video.gsURL = metadata!.gsURL
            FIRManager.shared.fetchDownloadURLs([URL(string: video.gsURL!)!], completion: {
                (urls) in
                video.videoURL = urls.first!.absoluteString
                
                // Put new video to Database with the new Storage url
                self.putObjectOnDatabase(named: ContentType.video.objectKey(), data: video.dictionaryFormat, completion: {
                    (ref, error) in
                    
                    if  error != nil {
                        print("Error- abort putting video")
                        return
                    }
                    print("Success: uploaded video")
                    
                    completion?()
                })
            })
            
        })
    }
    
    func uploadVideoComposition(composition: VideoComposition, completion:(()->())?) {
        var newData = composition.dictionaryFormat
        
        // Upload audio to Storage and get new audio Storage url to newData
        self.putObjectOnStorage(url: composition.audioURL!, contentType: .audio, completion:
            { (metadata, error) in
            
                // Update Storage gs url into Database object
            
                newData[VideoComposition.Key.gsAudioURL] = self.storageAbsoluteURL(metadata!) as AnyObject
            
                
                let gsURL = URL(string: self.storageAbsoluteURL(metadata!))
                FIRManager.shared.fetchDownloadURLs([gsURL!], completion: { (urls) in
                newData[VideoComposition.Key.audioURL] = urls.first?.absoluteString as AnyObject
                print("Success: uploaded audio")
                
                // Upload the video URLs to Storage and get new video Database urls into newData
                // Generate array of download urls
                var gsVideoURLs: [String] = Array(repeating: "nil", count: composition.videoURLs.count)
                var didFinish = 0
                for i in 0..<composition.videoURLs.count {
                    let index = i
                    self.putObjectOnStorage(url: composition.videoURLs[index], contentType: .video, completion: {
                        (metadata, error) in
                        
                        let urlString = self.storageAbsoluteURL(metadata!)
                        gsVideoURLs[index] = urlString
                        
                        print("Success: uploaded video \(index + 1) of \(composition.videoURLs.count): \(urlString)")
                        didFinish += 1
                        
                        if didFinish == gsVideoURLs.count {
                            // Upload the new array of download urls
                            newData[VideoComposition.Key.gsVideoURLs] = gsVideoURLs as AnyObject
                            
                            FIRManager.shared.fetchDownloadURLs(urlStrings: gsVideoURLs, completion: { (urls) in
                                
                                var urlStrings: [String] = []
                                for url in urls {
                                    let absString = url.absoluteString
                                    urlStrings.append(absString)
                                }
                                newData[VideoComposition.Key.videoURLs] = urlStrings as AnyObject
                                
                                // Put new Template object to Database
                                self.putObjectOnDatabase(named: ContentType.template.objectKey(), data: newData, completion: {
                                    (templateDatabaseReference, error) in
                                    if  error != nil {
                                        print("Error- abort putting template")
                                        return
                                    }
                                    print("Success: created template object on Database, path: \(templateDatabaseReference.url)")
                                    
                                    // Update template ID
                                    templateDatabaseReference.updateChildValues([VideoComposition.Key.templateID: templateDatabaseReference.key])
                                    
                                    completion?()
                                })
                            })
                            
                        }
                    })
                }
            })
        })
    }
    
    func fetchDownloadURLs(urlStrings: [String], completion: @escaping ([URL])->()) {
        var newURLs: [URL] = []
        
        for string in urlStrings {
            let url = URL(string: string)
            newURLs.append(url!)
        }
        
        fetchDownloadURLs(newURLs, completion: completion)
    }
    
    func fetchDownloadURLs(_ urls: [URL], completion: @escaping ([URL])->()) {
        // To capture new URLs
        var newURLs = urls
        // Track completions
        var completed = 0
        // Track todos
        var todo = newURLs.count
        
        for i in 0..<newURLs.count {
            let index = i
            let cloudURL = newURLs[index]
            if cloudURL.absoluteString.isCloudStorage {
                FIRManager.shared.storage(url: cloudURL.absoluteString).downloadURL(completion: { (url, error) in
                    if let error = error {
                        print("Error getting download URL for cloud object, aborting: \(error.localizedDescription)")
                        return
                    }
                    newURLs[index] = url!
                    print("new url: \(newURLs[index])")
                    completed += 1
                    
                    // check for last item to complete
                    if completed == todo {
                        completion(newURLs)
                    }
                })
            }
            else {
                todo -= 1
            }
        }
    }
}

// MARK:- Extensions

extension FIRDatabaseReference {
    // Push new "object" to FIR Database
    // Object data is dictionary of String: AnyObject? format
    // Resulting reference (& .key) is handed to completion block as FIRDatabaseReference
    
    func addObject(named: String, data: [String: AnyObject?], completion:@escaping (FIRDatabaseReference, Error?)->()) {
        // Put to Database
        child(named).childByAutoId().setValue(data){ (error, ref) in
            if let error = error {
                print("Error adding object to FIR Database: \(error.localizedDescription)")
            }
            completion(ref, error)
        }
    }
    
    func exists(_ block:@escaping (Bool) -> ()) {
        observeSingleEvent(of: .value, with: { (snapshot) in
            block(snapshot.exists())
        })
    }
}


extension FIRStorageReference {
    func addObject(data: Data, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        let path = contentType.objectKey() + "/" + FIRManager.shared.uniqueIdentifier + contentType.fileExtension()
        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType.string()

        // Put to Storage

        child(path).put(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
            }
            completion(metadata, error)
        }
    }
    
    func addObject(url: URL, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        let path = contentType.objectKey() + "/" + FIRManager.shared.uniqueIdentifier + contentType.fileExtension()
        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType.string()
        
        child(path).putFile(url, metadata: metadata) { (fir, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
            }
            completion(metadata, error)
        }
    }
}

extension FIRDataSnapshot {
    var dictionary: [String: AnyObject?] {
        get {
            return self.value as! [String: AnyObject?]
        }
    }
}

extension String {
    var isCloudStorage: Bool {
        get {
            return self.hasPrefix("gs://")
        }
    }
}

extension FIRStorageMetadata {
    var gsURL: String {
        get {
            return FIRManager.shared.storage.child(self.path!).description
        }
    }
}

extension UIImageView {
    // Load an image from Google Storage and layover busy indicator over imageView during load
    func loadImageFromGS(with storageRef: FIRStorageReference, placeholderImage placeholder: UIImage?) {
        if let task = self.sd_setImage(with: storageRef, placeholderImage: placeholder) {
            let busyIndicator = UIActivityIndicatorView(frame: self.bounds)
            self.addSubview(busyIndicator)
            busyIndicator.startAnimating()

            task.observe(.success, handler: { (snapshot: FIRStorageTaskSnapshot) in
                busyIndicator.removeFromSuperview()
            })
            task.observe(.failure, handler: { (snapshot: FIRStorageTaskSnapshot) in
                busyIndicator.removeFromSuperview()
            })
        }
    }
}
