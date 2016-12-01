//
//  Restaurant.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class Restaurant: NSObject {
    let name: String?
    let address: String?
    
    init(dictionary: [String:AnyObject?]) {
        name = dictionary["name"] as? String
        let location = dictionary["location"] as? [String:AnyObject?]
        var address = ""
        if let location = location {
            let addressArray = location["address"] as? [String]
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0]
            }
        }
        self.address = address
    }
    
    class func restaurants(array: [[String:AnyObject?]]) -> [Restaurant] {
        var restaurants = [Restaurant]()
        for dictionary in array {
            let restaurant = Restaurant(dictionary: dictionary)
            restaurants.append(restaurant)
        }
        return restaurants
    }
    
    class func searchWithTerm(term: String, completion: @escaping ([Restaurant]?, Error?) -> Void) {
        _ = YPManager.shared.searchWithTerm(term, completion: completion)
    }
    
}
