//
//  JSONStack.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

/**
 Class that creates and manages a 'queue' in JSON given any child in JSON tree
 Queue is stored in sub path: ~/queue
 Count of the queue is maintained by adding and removing timestamped children under /queue/count
 */
class JSONStack: NSObject {
    /**
     Queue object onto JSON stack
     */
    class func queue(object: [String: AnyObject?], database: FIRDatabaseReference) {
        // Add object to stack with timestamped key as parent (childByAutoID)
        // Path: ~/queue
        database.child(keys.object).childByAutoId().updateChildValues(object)
    }
    
    /**
     Pop next object from JSON stack FIFO
     */
    class func popFIFO(database: FIRDatabaseReference, completion:@escaping (FIRDataSnapshot?)->()) {
        // append "queue" to JSON path
        let database = database.child(keys.object)
        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            // test if empty (then return nil)
            if (snapshot.childrenCount < 1) || (!snapshot.exists()) {
                completion(nil)
            } else { // otherwise pop from queue and send to handler
                // get first child objectToPop
                var firstChild: FIRDataSnapshot?
                for snapChild in snapshot.children {
                    if let snapChild = snapChild as? FIRDataSnapshot {
                        firstChild = snapChild
                    }
                    break
                }
                if let firstChild = firstChild {
                    // pop from queue & return
                    database.child(firstChild.key).removeValue()
                    
                    var objectToPop: FIRDataSnapshot?
                    // remove JSONStack generated auto key
                    for snapChild in firstChild.children {
                        if let snapChild = snapChild as? FIRDataSnapshot {
                            objectToPop = snapChild
                        }
                        break
                    }
                    
                    completion(objectToPop)
                } else {
                    print("Error, tried to pop item off queue; resulted in nil error")
                }
            }
        })
    }
    
    /**
     Count the number of items in queue.  Implemented by counting the number of children under /queue
     */
    class func count(database: FIRDatabaseReference, completion:@escaping (UInt)->()) {
        database.child(keys.object).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
    }
    
    struct keys {
        static var object = "queue"
    }
}
