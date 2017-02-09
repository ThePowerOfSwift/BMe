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
        queueDatabase(database).childByAutoId().updateChildValues(object)
    }
    
    /**
     Pop x objects from JSONStack in FIFO order
     Return resulting array to handler
     */
    class func popFIFO(_ count: Int, database: FIRDatabaseReference, completion:@escaping ([[String: AnyObject?]])->()) {
        let database = queueDatabase(database)
        // Result holder
        var result: [[String: AnyObject?]] = []
        
        // Sanity check
        if (count <= 0) {
            completion(result)
            return
        }
        
        // Run transaction block to pop objects from stack
        database.runTransactionBlock({ (currentQueue) -> FIRTransactionResult in
            // If queue exists (non nil) and has enough objects to pop (>= count)
            if var queue = currentQueue.value as? [String: AnyObject?],
                (Int(currentQueue.childrenCount) >= count) {
                
                // Get the top object on stack and pop, "count" times
                for _ in 1...count {
                    let keyToPop = queue.keys.sorted()[0]
                    let objectToPop = queue[keyToPop] as? [String: AnyObject?]
                    result.append(objectToPop!)
                    queue.removeValue(forKey: keyToPop)
                }
                                
                // Commit pop to database
                currentQueue.value = queue
                return FIRTransactionResult.success(withValue: currentQueue)
            }
            return FIRTransactionResult.success(withValue: currentQueue)
        }, andCompletionBlock: { (error, committed, nil) in
            if let error = error {
                print("Error popping object from stack: \(error.localizedDescription)")
            }
            completion(result)
        })
    }
    
    /**
     Count the number of items in queue.  Implemented by counting the number of children under /queue
     */
    class func count(database: FIRDatabaseReference, completion:@escaping (UInt)->()) {
        queueDatabase(database).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.childrenCount)
        })
    }
    
    /** 
     Return the prefix "queue" reference with database ref as root
     */
    private class func queueDatabase(_ database: FIRDatabaseReference) -> FIRDatabaseReference {
        // Path: ~/queue
        return database.child(keys.queue)
    }
    
    /** Keys to access database objects */
    struct keys {
        static var queue = "queue"
    }
}
