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
    
    var matchupTableViewDataSource: [MatchupTableViewDataSource]?
    var matchupTitle: String?


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
        print("tableViewHeight: \(tableViewHeight) in Category Table view controller")
        //tableView.isUserInteractionEnabled = false
        //self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedSectionHeaderHeight = 25
    }
}

extension CategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let matchupTableViewDataSource = matchupTableViewDataSource else {
            return 0
        }
        return matchupTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewController.cellIdentifier, for: indexPath) as? CategoryTableViewCell, let matchupTableViewDataSource = matchupTableViewDataSource else {
            let cell = UITableViewCell()
            return cell
        }
        
        cell.photoImageView.image = matchupTableViewDataSource[indexPath.row].image
        cell.photoImageView.backgroundColor = UIColor.red
        cell.categoryNameLabel.text = matchupTableViewDataSource[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let matchupTitle = matchupTitle else {
            return "No title"
        }
        return matchupTitle
    }
    
    func makeHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tableViewSectionHeaderHeight))
        headerView.backgroundColor = UIColor.blue
        // make title label
        

        
        // make show more button
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenWidth = UIScreen.main.bounds.width
        //let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableViewSectionHeaderHeight))
        //headerLabel.text = "Label"
        //headerLabel.backgroundColor = UIColor.green
       // let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableViewSectionHeaderHeight))
        //headerView.backgroundColor = UIColor.blue
        //return headerLabel
        
        guard let matchupTitle = matchupTitle else {
            print("matchupTitle is nil")
            return nil
        }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.blue
        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColor.green

        //headerView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        headerLabel.text = matchupTitle
        headerLabel.text = "TITLE"
        headerView.addSubview(headerLabel)
        headerView.addConstraints([
            NSLayoutConstraint(
                item: headerLabel,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: headerLabel,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1.0,
                constant: 20
            ),
            NSLayoutConstraint(
                item: headerLabel,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.height,
                multiplier: 1.0,
                constant: 20
            ),
            NSLayoutConstraint(
                item: headerLabel,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.width,
                multiplier: 1.0,
                constant: 100
            )])
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSectionHeaderHeight
    }
    
    
}
