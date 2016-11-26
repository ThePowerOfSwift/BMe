//
//  TestVideosViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class TemplateListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var templates: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure FIR database
        _refHandle = FIRManager.shared.observeDatabaseObject(named: FIRManager.ObjectKey.template, event: .childAdded) { (snapshot) in
            self.templates.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.templates.count - 1, section: 0)], with: .automatic)
        }
        // Configure FIR storage
        
    }

    // On dealloc unsubscribe from object observation
    deinit {
        FIRManager.shared.unobserveDatabaseObject(named: FIRManager.ObjectKey.video, handle: _refHandle)
    }
    
    
    // MARK: - TableView datasource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .detailDisclosureButton
        let data = templates[indexPath.row].dictionary
        
        cell.textLabel?.text = data[VideoComposition.Key.templateID] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let template = VideoComposition(dictionary: templates[indexPath.row].dictionary)
        present(template.playerViewController, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let data = templates[indexPath.row].dictionary
        
        // Render the file
        VideoComposition(dictionary: data).render(fileNamed: "render_temp.mov", completion: {
            (session: AVAssetExportSession) in
            print("Success: rendered video")
            
            // Convert rendered to upload video with using updated links
            let video = Video(userId: AppState.shared.currentUser?.uid,
                              username: AppState.shared.currentUser?.displayName,
                              templateId: data[VideoComposition.Key.templateID] as? String,
                              videoURL: session.outputURL?.absoluteString,
                              gsURL: "",
                              createdAt: Date(),
                              restaurantName: ""
                              )
            
            FIRManager.shared.uploadVideo(video: video, completion: {
                let url = URL(string: video.videoURL!)
                let player = AVPlayer(url: url!)
                let vc = AVPlayerViewController()
                vc.player = player
                
                self.present(vc, animated: true, completion: {
                })
            })
            
            
        })
        
    }
}
