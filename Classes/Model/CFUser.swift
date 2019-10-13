//
//  User.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

public protocol CFUserProtocol: Codable {
     var _id: String? { get set }
     var email: String? { get set }
     var username: String? { get set }
     var chatRooms: [String]? { get set }
}

public struct CFUser: Equatable, CFUserProtocol {
    public var _id: String?
    public var email: String?
    public var username: String?
    public var chatRooms: [String]?

    public static func ==(lhs: CFUser, rhs: CFUser) -> Bool {
        return lhs._id == rhs._id
    }
}

extension CFUser {
    static func save(user: CFUser?, with key: String) {
        if let user = user, let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            UserDefaults.standard.set(nil, forKey: key)
        }
    }
    
    static func get(from userDefaultsKey: String) -> CFUser? {
        guard let savedPerson = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data else
        { return nil}
        return try? JSONDecoder().decode(CFUser.self, from: savedPerson)
    }
}
