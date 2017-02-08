//
//  MeasurementHelper.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        FIRAnalytics.logEvent(withName: keys.logout, parameters: nil)
    }
    
    static func sendMessageEvent() {
        FIRAnalytics.logEvent(withName: keys.message, parameters: nil)
    }
    
    static func sendOpenEvent() {
        FIRAnalytics.logEvent(withName: keys.open, parameters: nil)
    }
    
    static func sendTakePictureEvent() {
        FIRAnalytics.logEvent(withName: keys.takePicture, parameters: nil)
    }
    
    static func sendSubmitPictureEvent() {
        FIRAnalytics.logEvent(withName: keys.submitPiture, parameters: nil)
    }
    
    static func sendDidSignupEvent() {
        FIRAnalytics.logEvent(withName: keys.didSignUp, parameters: nil)
    }
    
    static func sendStartedSignupEvent() {
        FIRAnalytics.logEvent(withName: keys.startedSignUp, parameters: nil)
    }
    
    struct keys {
        static var open = "open"
        static var logout = "logout"
        static var message = "message"
        static var takePicture = "takePicture"
        static var submitPiture = "submitPicture"
        static var didSignUp = "didSignup"
        static var startedSignUp = "startedSignup"
    }
}
