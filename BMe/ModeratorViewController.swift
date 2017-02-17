//
//  ModeratorViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/17/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let navBarTitle = "Matchups"
private let reuseIdentifier = PostTableViewCell.keys.nibName
private let cellClass = PostTableViewCell.self

class ModeratorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Properties
    @IBOutlet weak var tableView: UITableView!
    
    /** Model */
    var posts: [Post] = []
    
    // FIR
    fileprivate var _refHandle: FIRDatabaseHandle?
    // database path to matchup queue
    private var database = Matchup.queue()
    private var isFetchingData = false
    private let fetchBatchSize = 10
    private(set) var lastFetchedKey: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Configure top (Nav Bar and TVC behaviour)
        title = navBarTitle
        // Add padding so top of TVC not covered by nav bar title
        automaticallyAdjustsScrollViewInsets = true
        // Hide nav bar on swipe
        navigationController?.hidesBarsOnSwipe = true
        
        // Setup plain style TV
        tableViewSetup()
        setupDatasource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Methods
    
    func tableViewSetup() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
        
        // Formatting
        tableView.backgroundColor = UIColor.white
        
        // Row height
        tableView.estimatedRowHeight = tableView.frame.width
        //        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) { 
        }
    }

    
    @IBAction func didTapMatchupQueue(_ sender: UIBarButtonItem) {
    }
    
    // MARK: TableView Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        
        cell.post = post
        
        return cell
    }
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
        
    }
    
    // MARK: FIR Methods
    
    func setupDatasource() {
        // Setup datasource
        if let _refHandle = _refHandle {
            database.removeObserver(withHandle: _refHandle)
        }
        self.posts.removeAll()
        self.tableView.reloadData()
        
        // Reverse load posts from most recent onwards
        _refHandle = database.queryLimited(toLast: UInt(fetchBatchSize)).observe(.childAdded, with: { (snapshot) in
            
            // Get the post associated with match queue object
            if let matchupQueuedPost = snapshot.value as? [String: AnyObject?],
                let postID = matchupQueuedPost[Matchup.keys.queueKey] as? String {
            
                Post.get(ID: postID, completion: { (post) in
                    // Add post to model and insert into table
                    self.posts.insert(post, at: 0)
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                })
            }
        })
    }
    
    // Deregister for notifications
    deinit {
        database.removeObserver(withHandle: _refHandle!)
    }
    
    // Performs a fetch to get more data
    func fetchMoreDatasource() {
        if !isFetchingData {
            isFetchingData = true
            
            // Get the "next batch" of posts
            // Request with upper limit on the last loaded post with a lower limit bound by batch size
            let lastPost = posts[posts.count - 1]
            database.queryEnding(atValue: lastPost.ID).queryLimited(toLast: UInt(fetchBatchSize)).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    
                    // returns posts oldest to youngest, inclusive, so remove last child
                    // and reverse to revert to youngest to oldest order (or reverse and remove first child)
                    var ignoreFirst = true
                    for child in snapshot.children.reversed() {
                        if ignoreFirst { //ignore reference post and add the rest
                            ignoreFirst = false
                        }
                        else {
                            let post = Post(child as! FIRDataSnapshot)
                            // append data
                            self.posts.append(post)
                            // load into tv
                            self.tableView.insertRows(at: [IndexPath(row: self.posts.count - 1, section: 0)], with: .top)
                        }
                    }
                    self.isFetchingData = false
            })
        }
    }
}
