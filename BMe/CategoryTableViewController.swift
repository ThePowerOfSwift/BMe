//
//  CategoryTableViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/3/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class CategoryTableViewController: UIViewController {
    
    fileprivate static let cellIdentifier = "CategoryTableViewCell"
    fileprivate static let tableViewSectionHeaderHeight: CGFloat = 50
    fileprivate static let section = 0
    fileprivate static let numberOfCellsShownInHomeViewController = 5
    
    /** Determine where the table view used. Table view is used in home view controller with small size and in category table view controller with full screen size. */
    fileprivate var isFullScreen: Bool = false
    /** Store contents to show in matchup table view. value assigned in home view controller.*/
    internal var matchupTableViewDataSource: [MatchupTableViewDataSource]?
    /** Shows titles like "Trending"*/
    internal var matchupTitle: String?
    /** Where title and show more button exist*/
    fileprivate var sectionHeaderView: UIView?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = Styles.Color.Primary
        tableView.backgroundColor = Styles.Color.Primary
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        // Autolayout is not possible because tableView is added into HomeViewController's subview
        let tableViewRowPartHeight = tableView.rowHeight * CGFloat(tableView.numberOfRows(inSection: CategoryTableViewController.section))
        let tableViewSectionHeaderHeight = tableView(tableView, heightForHeaderInSection: CategoryTableViewController.section)
        // number of rows * row height + header view height = table view height
        let tableViewHeight = tableViewRowPartHeight + tableViewSectionHeaderHeight
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tableViewHeight)
        makeSectionHeaderView()
        
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
    
    /** Initialize and configure sectionHeaderView. */
    private func makeSectionHeaderView() {
        
        guard let matchupTitle = matchupTitle else {
            print("matchupTitle is nil")
            return
        }
        
        // Create label to show title
        let headerLabel = UILabel()
        //headerLabel.backgroundColor = UIColor.green
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = matchupTitle
        headerLabel.textColor = Styles.Color.Tertiary
        
        // Create header view
        self.sectionHeaderView = UIView()
        guard let headerView = sectionHeaderView else {
            print("sectionHeaderView is nil")
            return
        }
        
        headerView.backgroundColor = Styles.Color.Primary
        
        // Add constraint
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
            )
        ])
        
        // Create show more button
        let showMoreButton = UIButton()
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.setTitle("show more", for: UIControlState.normal)
        showMoreButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        showMoreButton.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
        showMoreButton.addTarget(self, action: #selector(onShowMoreButton(sender:)), for: UIControlEvents.touchUpInside)
        
        // Add constraint
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
            )
        ])
    }
}

extension CategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Limit the table view number of rows when table view is in home view controller with smaller size
        if !isFullScreen {
            guard matchupTableViewDataSource != nil else {
                return 0
            }
            return CategoryTableViewController.numberOfCellsShownInHomeViewController
        }
        
        // If full screen, show all the items in data source
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
        cell.categoryNameLabel.text = matchupTableViewDataSource[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let matchupTitle = matchupTitle else {
            return "No title"
        }
        return matchupTitle
    }
    
    // http://stackoverflow.com/questions/27860126/viewforheaderinsection-autolayout-pin-width
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func onShowMoreButton(sender: UIButton) {
        print("Show more button tapped")
        showFullTableView()
    }
    
    /** Show full screen table view*/
    func showFullTableView() {
        let storyboard = UIStoryboard(name: Constants.SegueID.Storyboard.Home, bundle: nil)
        guard let fullCategoryTVC = storyboard.instantiateViewController(withIdentifier: HomeViewController_old.viewControllerID) as? CategoryTableViewController else {
            print("failed to instantiate CategoryTableViewController")
            return
        }
        
        fullCategoryTVC.matchupTableViewDataSource = matchupTableViewDataSource
        fullCategoryTVC.isFullScreen = true
        fullCategoryTVC.title = matchupTitle
        fullCategoryTVC.fullScreenTableView()
        
        navigationController?.pushViewController(fullCategoryTVC, animated: true)
    }
    
    /** Apply autolayout to table view to make it full screen. Called when full screen table view controller is used. */
    func fullScreenTableView() {
        
        // To initialize tableView outlet in fullCategoryTVC
        self.view.layoutIfNeeded()
        guard let fullTableView = self.tableView else {
            print("failed to get full table view from CategoryTableViewController")
            return
        }
        
        fullTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: fullTableView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: 0
            ),
        ])
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
        return CategoryTableViewController.tableViewSectionHeaderHeight
    }
}
