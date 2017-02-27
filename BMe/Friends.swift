//
//  Friends.swift
//  BMe
//
//  Created by Lu Ao on 2/26/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Friends: JSONObject {
    override class var object: FIR.object {
        get {
            return FIR.object.friends
        }
    }
    
    private (set) var friendCount = 0
    private (set) var firendList = [String:Bool]()
    private (set) var autoFriend = Bool()
    
    override init(_ snapshot: FIRDataSnapshot) {
        super.init(snapshot)
        let friendInfo = snapshot.value as! [String:Any]
        self.firendList = friendInfo[keys.friends] as! [String:Bool]
        self.autoFriend = friendInfo[keys.autofriend] as! Bool
    }
    
    /**
     Create a friend in the friend list when adding a person as friend; or
     - Parameter postID: String
     - Parameter uID: Sting
     */
    //TODO: Determine if autofriend should be in a separate table, because it loads whole friend list even if only the autofirend is nedded; Or not because it has to load the whole list to update the FOF table
    class func addFriendToList(FriendUID: String) {
        let uid = UserAccount.currentUser.uid!
        Friends.get(UID: FriendUID) { (newFriend) in
            if newFriend.autoFriend{// if target user set autofriend anyone, then auto confirm both user friends.
                FIR.manager.databasePath(object).child(uid).child(keys.friends).child(FriendUID).setValue(true)
                FIR.manager.databasePath(object).child(FriendUID).child(keys.friends).child(uid).setValue(true)
                //TODO: Update FriendOfFriend list append the friend's friend table
            }
            else{
                FIR.manager.databasePath(object).child(uid).child(keys.friends).child(FriendUID).setValue(false)
                FIR.manager.databasePath(object).child(FriendUID).child(keys.friends).child(uid).setValue(false)
                //TODO: Make notification queue to alert target user to confirm friend

            }
        }
    }
    
    //Switch autofriend On/Off
    class func switchAutoFriend(isOn: Bool){
        let uid = UserAccount.currentUser.uid!
        FIR.manager.databasePath(object).child(uid).child(keys.autofriend).setValue(isOn)
    }
    
    class func confirmFriend(FriendUID: String, completion: () -> ()){
        let uid = UserAccount.currentUser.uid!
        FIR.manager.databasePath(object).child(uid).child(keys.friends).child(FriendUID).setValue(true)
        FIR.manager.databasePath(object).child(FriendUID).child(keys.friends).child(uid).setValue(true)
        //TODO: Update FriendOfFriend list append the friend's friend list
    }
    
    /**
     Retrieve friendInfo
     */
    class func get(UID: String, completion:@escaping (Friends)->()) {
        super.get(UID, object: object) { (snapshot) in
            // return initialized object
            completion(Friends(snapshot))
        }
    }
    
    class func createList(){
        let uid = UserAccount.currentUser.uid!
        FIR.manager.databasePath(object).child(uid).child(keys.autofriend).setValue(true)

    }
    
    /**
     Get friend list for current user
    */
    class func getMyfriendList() -> Friends?{
        var list: Friends?
        Friends.get(UID: UserAccount.currentUser.uid!) { (Friends) in
            list = Friends
        }
        return list
    }
    
    /** Database keys */
    struct keys {
        static let uid = "uid"
        static let users = "users"
        static let postid = "postid"
        static let status = "status"
        static let count = "count"
        static let autofriend = "autofriend"
        static let friends = "friends"
    }
    
}
