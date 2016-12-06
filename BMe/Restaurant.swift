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
    let yelpID: String?
    
    var dictionary: [String: AnyObject?] {
        return ["contentType": ContentType.restaurantMeta.string() as AnyObject,
                Key.name: self.name as AnyObject,
                Key.address: self.address as AnyObject,
                Key.id: self.yelpID as AnyObject,
        ]
    }
    
    init(dictionary: [String:AnyObject?]) {
        self.name = dictionary[Key.name] as? String
        self.yelpID = dictionary["id"] as? String
        
        let location = dictionary[Key.location] as? [String:AnyObject?]
        var address = ""
        if let location = location {
            let addressArray = location[Key.address] as? [String]
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
    
    struct Key {
        static let name = "name"
        static let location = "location"
        static let address = "address"
        static let id = "id"
    }
}
