//
//  NetworkResponse.swift
//  ios-foundation
//
//  Created by Robert on 7/7/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

struct SignInResponse: Codable {
    var token: String
    var user: CFUser
}

struct ResponseError: Codable {
    var error: String?
}

struct ResponseValidationError: Codable {
    var isJoi: Bool
    var name: String
    var details: [NetworkError]
}

