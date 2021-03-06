//
//  YPManager.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager


class YPManager: BDBOAuth1RequestOperationManager {
    // Keys: http://www.yelp.com/developers/manage_api_keys
    static let consumerKey = "d71OERag3IlBlTkPzf9ZmQ"
    static let consumerSecret = "GxtaBKQK4iJG5O4xr_q0ENjFD5s"
    static let token = "dBr1YFujiBedgAEv5Ne5Z5RgatPehDwy"
    static let tokenSecret = "1q5xBQJIYTqeSDjHYXJvOEee9h4"
    static let baseURL = "https://api.yelp.com/v2/"
    
    static let shared = YPManager(consumerKey: YPManager.consumerKey,
                                  consumerSecret: YPManager.consumerSecret,
                                  accessToken: YPManager.token,
                                  accessSecret: YPManager.tokenSecret)
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        let baseURL = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseURL!, consumerKey: key, consumerSecret: secret);
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchWithTerm(_ term: String?, _ options: [String : AnyObject]?, completion: @escaping ([Restaurant]?, Error?) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Defaults
        var parameters: [String : AnyObject] = [Key.term: (term ?? "") as AnyObject,
                                                // location San Francisco
                                                Key.ll : "37.785771,-122.406165" as AnyObject,
                                                //Sort mode: 0=Best matched (default), 1=Distance, 2=Highest Rated
                                                Key.sort: 0 as AnyObject]
        if let options = options {
            for entry in options {
                parameters.updateValue(entry.value as AnyObject, forKey: entry.key)
            }
        }
        
        print(parameters)
        
        return self.get("search", parameters: parameters,
                        success: { (operation: AFHTTPRequestOperation, response: Any) -> Void in
                            if let response = response as? [String: Any]{
                                let dictionaries = response["businesses"] as? [[String:AnyObject?]]
                                if dictionaries != nil {
                                    
                                    // Get array of restaurants
                                    completion(Restaurant.restaurants(array: dictionaries!), nil)
                                }
                            }
        },
                        failure: { (operation: AFHTTPRequestOperation?, error: Error) -> Void in
                            completion(nil, error)
        })!
    }
    
    struct Key {
        static let term = "term"
        static let ll = "ll"
        static let limit = "limit"
        static let offset = "offset"
        static let sort = "sort"
        static let category_filter = "category_filter"
        static let radius_filter = "radius_filter"
        static let deals_filter = "deals_filter"
    }
}
