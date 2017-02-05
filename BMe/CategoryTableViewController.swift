//
//  CategoryTableViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/3/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class CategoryTableViewController: UIViewController {
    
    static let cellIdentifier = "CategoryTableViewCell"
    let tableViewSectionHeaderHeight: CGFloat = 50

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Autolayout is not possible because tableView is added into HomeViewController's subview
        let rowHeight = tableView.rowHeight
        let screenWidth = UIScreen.main.bounds.width
        
        // hearder view with height 30
        //let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        //headerView.backgroundColor = UIColor.cyan
        //tableView.tableHeaderView = headerView
        
//        let tableViewHeight = rowHeight * CGFloat(tableView.numberOfRows(inSection: 0)) + tableView.sectionHeaderHeight
        let tableViewHeight = rowHeight * CGFloat(tableView.numberOfRows(inSection: 0)) + tableView(tableView, heightForHeaderInSection: 0)
        let tableViewWidth = UIScreen.main.bounds.width
        tableView.frame = CGRect(x: 0, y: 0, width: tableViewWidth, height: tableViewHeight)
        tableView.isScrollEnabled = false
        //tableView.isUserInteractionEnabled = false
        //self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedSectionHeaderHeight = 25
    }
}

extension CategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewController.cellIdentifier, for: indexPath) as? CategoryTableViewCell else {
            let cell = UITableViewCell()
            return cell
        }
        
        cell.photoImageView.backgroundColor = UIColor.red
        cell.categoryNameLabel.text = "BLANK NAME"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TITLE"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenWidth = UIScreen.main.bounds.width
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableViewSectionHeaderHeight))
        headerLabel.text = "Label"
        headerLabel.backgroundColor = UIColor.green
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableViewSectionHeaderHeight))
        headerView.backgroundColor = UIColor.blue
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSectionHeaderHeight
    }
    
}
