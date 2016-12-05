//
//  YelpViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import CoreLocation

protocol YelpViewControllerDelegate: class {
    func yelp(didSelect restaurant: Restaurant)
}

class YelpViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    // API
    let yelp = YPManager.shared
    // Location
    let locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D?
    // First call
    var isSetup = false
    
    // Constants
    static let kYelpTableViewCellID = "YelpTableViewCell"
    static let rowheight: CGFloat = 80.0
    
    // Model
    var restaurants: [Restaurant]? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: YelpViewControllerDelegate?
    
    @IBOutlet weak var restuarantNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
//    @IBAction func tappedDone(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        restuarantNameTextField.delegate = self
        restuarantNameTextField.becomeFirstResponder()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Styles.Color.Primary
        tableView.rowHeight = YelpViewController.rowheight
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Perform search based on current location
    func findClosest() {
        let parameters: [String: AnyObject] = [YPManager.Key.limit: 5 as AnyObject,
                                               YPManager.Key.sort: 1 as AnyObject]
        
        search("", parameters)
    }
    
    // Search using textfield value and given options
    func search(_ text: String, _ options: [String: AnyObject]?) {
        // Search based on current location
        var locationString: String?
        if let location = location {
            locationString = String(location.latitude) + "," + String(location.longitude)
        }
        var parameters: [String: AnyObject] = [YPManager.Key.ll: locationString as AnyObject,
                                               //Sort mode: 0=Best matched (default), 1=Distance, 2=Highest Rated,
                                                YPManager.Key.sort: 0 as AnyObject]
        // Override parameters with provided options
        if let options = options {
            for entry in options {
                parameters.updateValue(entry.value, forKey: entry.key)
            }
        }
        
        let _ = yelp.searchWithTerm(text, parameters, completion: {(restaurants, error) in
            self.listRestaurants(restaurants, error: error)
        })
    }

    // process results
    func listRestaurants(_ list:[Restaurant]?, error: Error?) {
        if let error = error {
            print("Error retrieving yelp restaurants \(error.localizedDescription)")
        }
        if let list = list {
            for restaurant in list {
                print(restaurant.name ?? "")
            }
        }
        self.restaurants = list
    }
    
    // MARK: - Textfield delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Generate complete text
        let nsText = textField.text as NSString?
        let text = nsText?.replacingCharacters(in: range, with: string)

        if (text!.isEmpty) {
            findClosest()
        }
        else {
            search(text! as String, nil)
        }
            
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        findClosest()
        return true
    }
    
    // MARK: - CLLocationManager Delegate delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last?.coordinate
        
        if !isSetup {
            findClosest()
            isSetup = true
        }
    }
    
    // MARK: - Tableview Datasource method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let restaurants = restaurants { return restaurants.count }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YelpViewController.kYelpTableViewCellID, for: indexPath)
        
        cell.backgroundColor = Styles.Color.Primary
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.shadowOffset = CGSize(width: 1, height: 1)
        cell.textLabel?.shadowColor = UIColor.black
    
        if let resto = restaurants?[indexPath.row] {
            cell.textLabel?.text = resto.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.yelp(didSelect: (restaurants![indexPath.row]))
        dismiss(animated: true, completion: nil)
    }
}
