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
        
        let data = templates[indexPath.row].dictionary
        let template = VideoComposition(dictionary: data)
        
        cell.textLabel?.text = template.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let template = VideoComposition(dictionary: templates[indexPath.row].dictionary)

    }
}
