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
    
    // Put file data to Storage: storagebucket/<content type>/<UID>/file...
    // Returns reference to uploaded file FIRStorageMetadata.gsURL
    func putObjectOnStorage(data: Data, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        let storage = FIRManager.shared.storage
        // Get unique path using UID as root
        let path = contentType.objectKey() + "/" + FIRManager.shared.uniqueIdentifier + contentType.fileExtension()
        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType.string()
        
        // Put to Storage
        storage.child(path).put(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
            }
            completion(metadata, error)
        }
    }

    // Put file reference by URL to Storage: storagebucket/<content type>/<UID>/file...
    // Returns reference to uploaded file FIRStorageMetadata.gsURL
    func putObjectOnStorage(url: URL, contentType: ContentType, completion: @escaping (FIRStorageMetadata?, Error?) -> ()) {
        let storage = FIRManager.shared.storage
        // Get unique path using UID as root
        let path = contentType.objectKey() + "/" + FIRManager.shared.uniqueIdentifier + contentType.fileExtension()
        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType.string()
        
        // Put to Storage
        storage.child(path).putFile(url, metadata: metadata) { (fir, error) in
            if let error = error {
                print("Error adding object to GS bucket: \(error.localizedDescription)")
            }
            completion(metadata, error)
        }
    }

    // Puts JSON object to database: database/<object key>/<Random Gen ID>/JSON object
    func putObjectOnDatabase(named: String, data: [String: AnyObject?], completion:@escaping (FIRDatabaseReference, Error?)->()) {
        let database = FIRManager.shared.database
        database.child(named).childByAutoId().setValue(data) { (error, ref) in
            if let error = error {
                print("Error adding object to FIR Database: \(error.localizedDescription)")
            }
            completion(ref, error)
        }
    }
    
    func postObject(url: URL, contentType: ContentType, meta: [String: AnyObject?], completion:(()->())?) {
        // Upload object to storage
        putObjectOnStorage(url: url, contentType: contentType, completion: { (metadata, error) in
            self.completePost(contentType: contentType, meta: meta, completion: completion, metadata: metadata, error: error)
        })
    }
    
    func postObject(object: Data, contentType: ContentType, meta: [String: AnyObject?], completion:(()->())?) {
        // Upload object to storage
        putObjectOnStorage(data: object, contentType: contentType, completion: { (metadata, error) in
            self.completePost(contentType: contentType, meta: meta, completion: completion, metadata: metadata, error: error)
        })
    }
    
    private func completePost(contentType: ContentType, meta: [String: AnyObject?], completion:(()->())?, metadata: FIRStorageMetadata?, error: Error?) {
        if let error = error {
            print("Error posting object \(contentType.string()), aborting: \(error.localizedDescription)")
            return
        }
        
        // Get resultant URLs and create object on Databasae
        let gsURL = metadata?.gsURL
        FIRManager.shared.fetchDownloadURLs([URL(string: gsURL!)!], completion: { (urls) in
            let downloadURL = urls.first!
            
            // Create object on Database
            
            // Construct JSON Asset object template to put on Database
            let jsonObject: [String: AnyObject?] = [
                Asset.Key.uid: AppState.shared.currentUser?.uid as AnyObject,
                Asset.Key.downloadURL: downloadURL.absoluteString as AnyObject,
                Asset.Key.gsURL: gsURL as AnyObject,
                Asset.Key.contentType: contentType.string() as AnyObject,
                Asset.Key.meta: meta as AnyObject]
            
            // Amend JSON object as needed
            switch contentType {
            case .image:
                break
            case .video:
                break
            default:
                break
            }
            print("About to post with JSON \(jsonObject)")
            self.putObjectOnDatabase(named: contentType.objectKey(), data: jsonObject, completion: { (ref, error) in
                if let error = error {
                    print("Error putting \(contentType.objectKey()) on Database, aborting \(error.localizedDescription)")
                    return
                }
                
                print("Success: uploaded \(contentType.objectKey())")
                
                // Create Post on Database
                
                // Construct JSON Post object to put on Database
                let jsonObject: [String: AnyObject?] = [
                    Post.Key.uid: AppState.shared.currentUser?.uid as AnyObject,
                    Post.Key.url: ref.url as AnyObject,
                    Post.Key.contentType: contentType.string() as AnyObject,
                    Post.Key.timestamp: Date().toString() as AnyObject
                    ]
                
                self.putObjectOnDatabase(named: ContentType.post.objectKey(), data: jsonObject, completion: { (ref, error) in
                    if let error = error {
                        print("Error putting \(contentType.objectKey()) on Database, aborting \(error.localizedDescription)")
                        return
                    }
                    print("Success: post created for \(contentType.objectKey())")
                    completion?()
                })
            })
        })
    }
    
    func rainCheckPost(_ postID: String) {
        print("Rainchecking post \(postID)")
        // Add postID for userMeta
        // Construct userMeta ref
        let metaRef = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(AppState.shared.currentUser!.uid)
        let raincheckRef = metaRef.child(UserMeta.Key.raincheck).child(postID)
        let meta: [String: AnyObject] = ["timestamp": Date().toString() as AnyObject]
        raincheckRef.setValue(meta)
    }
    
    func removeRainCheckPost(_ postID: String) {
        let metaRef = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(AppState.shared.currentUser!.uid)
        let raincheckRef = metaRef.child(UserMeta.Key.raincheck).child(postID)
        raincheckRef.removeValue()
    }
    
    func fetchPostsWithID(_ IDs: [String], completion: @escaping ([FIRDataSnapshot])->() ) {
        // Trackers
        var index = 0
        var completed = 0
        
        var snapshots = Array(repeatElement(FIRDataSnapshot(), count: IDs.count)) 
        print("Generating snapshots for \(snapshots.count)")
        
        for id in IDs {
            // Use a copied index to track for completion block later
            let currentIndex = index
            FIRManager.shared.database.child(ContentType.post.objectKey()).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                snapshots[currentIndex] = snapshot
                completed += 1
                
                if completed == IDs.count
                {
                    print("returning snapshots with count \(snapshots.count)")
                    completion(snapshots)
                }
            })
            index += 1
        }
        
    }
    
    func heartPost(_ postID: String) {
        print("Hearting post \(postID)")
        // Add postID for userMeta
        // Construct userMeta ref
        let metaRef = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(AppState.shared.currentUser!.uid)
        let heartRef = metaRef.child(UserMeta.Key.heart).child(postID)
        let meta: [String: AnyObject] = ["timestamp": Date().toString() as AnyObject]
        heartRef.setValue(meta)
    }
    
    func removeHeartPost(_ postID: String) {
        let metaRef = FIRManager.shared.database.child(ContentType.userMeta.objectKey()).child(AppState.shared.currentUser!.uid)
        let heartRef = metaRef.child(UserMeta.Key.heart).child(postID)
        heartRef.removeValue()
    }
    
    //TODO: - Should move this to VideoComposition
    func uploadVideoComposition(composition: VideoComposition, completion:(()->())?) {
        var newData = composition.dictionaryFormat
        
        // Upload audio to Storage and get new audio Storage url to newData
        self.putObjectOnStorage(url: composition.audioURL!, contentType: .audio, completion:
            { (metadata, error) in
            
                // Update Storage gs url into Database object
            
                newData[VideoComposition.Key.gsAudioURL] = metadata!.gsURL as AnyObject
            
                
                let gsURL = URL(string: metadata!.gsURL)
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
                        
                        let urlString = metadata!.gsURL
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
                FIRStorage.storage().reference(forURL: cloudURL.absoluteString).downloadURL(completion: { (url, error) in
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
    func exists(_ block:@escaping (Bool) -> ()) {
        observeSingleEvent(of: .value, with: { (snapshot) in
            block(snapshot.exists())
        })
    }
}


extension FIRDataSnapshot {
    var dictionary: [String: AnyObject?] {
        get {
            if self.childrenCount <= 0 { return [:] }
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
            
            task.observe(.progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
                if let progress = snapshot.progress {
                    let completed: CGFloat = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
//                    self.alpha = completed
                }
            })
            task.observe(.success, handler: { (snapshot: FIRStorageTaskSnapshot) in
//                self.alpha = 1
                busyIndicator.removeFromSuperview()
            })
            task.observe(.failure, handler: { (snapshot: FIRStorageTaskSnapshot) in
                if let error = snapshot.error {
                    print("Error loading image from GS \(error.localizedDescription)")
                }
                busyIndicator.removeFromSuperview()
            })
        }
    }
}
