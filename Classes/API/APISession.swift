//
//  APISession.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//


import Foundation

class APISession {

    static var token: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        } get {
            return UserDefaults.standard.string(forKey: "token")
        }
    }
    
    static var currentUser: CFUser? {
        set {
            CFUser.save(user: newValue, with: "cached_user")
            currentUserID = newValue?._id
        } get {
            return CFUser.get(from: "cached_user")
        }
    }
    
    static var customToken: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "custom_token")
        } get {
            return UserDefaults.standard.string(forKey: "custom_token")
        }
    }
    
    static var currentUserID: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "current_userid")
        } get {
            return UserDefaults.standard.string(forKey: "current_userid")
        }
    }
    
    static func logOut() {
        token = nil
        customToken = nil
        currentUser = nil
    }
}
