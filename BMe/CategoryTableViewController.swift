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
    
    var isFullScreen: Bool = false
    
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
        print("tableViewHeight: \(tableViewHeight) in Category Table view controller")
        //tableView.isUserInteractionEnabled = false
        //self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedSectionHeaderHeight = 25
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show or hide navigation bar. I had to do this in viewWillAppear 
        // because it's still nil in viewDidLoad
        if isFullScreen {
            navigationController?.navigationBar.isHidden = false
            tableView.isScrollEnabled = true
        } else {
            navigationController?.navigationBar.isHidden = true
            tableView.isScrollEnabled = false
        }
    }
}

extension CategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Limit the table view number of rows when 
        if !isFullScreen {
            guard matchupTableViewDataSource != nil else {
                return 0
            }
            return 5
        }
        
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
    
    // http://stackoverflow.com/questions/27860126/viewforheaderinsection-autolayout-pin-width
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
        
        headerLabel.text = matchupTitle
        headerView.addSubview(headerLabel)
        headerView.addConstraints([
            NSLayoutConstraint(
                item: headerLabel,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.centerY,
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
            )])
        
        let showMoreButton = UIButton()
        showMoreButton.backgroundColor = UIColor.green
        
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.setTitle("show more", for: UIControlState.normal)
        showMoreButton.setTitleColor(UIColor.white, for: .normal)
        showMoreButton.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
        showMoreButton.addTarget(self, action: #selector(onShowMoreButton(sender:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(showMoreButton)
        
        headerView.addConstraints([
            NSLayoutConstraint(
                item: showMoreButton,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: showMoreButton,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1.0,
                constant: -20
            ),
            NSLayoutConstraint(
                item: showMoreButton,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: headerView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0
            )])
        return headerView
    }
    
    func onShowMoreButton(sender: UIButton) {
        print("Show more button tapped")
        showFullTableView()
    }
    
    func showFullTableView() {
        let storyboard = UIStoryboard(name: HomeViewController.storyboardID, bundle: nil)
        guard let fullCategoryTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.viewControllerID) as? CategoryTableViewController else {
            print("failed to instantiate CategoryTableViewController")
            return
        }
        
        fullCategoryTVC.matchupTableViewDataSource = matchupTableViewDataSource
        fullCategoryTVC.isFullScreen = true
        fullCategoryTVC.view.layoutIfNeeded()
        guard let fullTableView = fullCategoryTVC.tableView else {
            print("failed to get full table view from CategoryTableViewController")
            return
        }
        
        fullTableView.translatesAutoresizingMaskIntoConstraints = false
        fullCategoryTVC.view.addConstraints([
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: fullCategoryTVC.view,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: fullCategoryTVC.view,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: fullCategoryTVC.view,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: fullCategoryTVC.view,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 0
            ),
        ])
        
        fullCategoryTVC.title = matchupTitle
        
        //present(fullCategoryTVC, animated: true, completion: nil)
        navigationController?.pushViewController(fullCategoryTVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // If the table view is full screen after show more button is tapped
        // Hide section header
        if isFullScreen {
            return 0 
        }
        return tableViewSectionHeaderHeight
    }
    
    
}

extension UIButton {
    
}
