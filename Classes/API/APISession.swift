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
    
    static var currentUser: User? {
        set {
            User.save(user: newValue, with: "cached_user")
        } get {
            return User.get(from: "cached_user")
        }
    }
    
    static func logOut() {
        currentUser = nil
    }
}