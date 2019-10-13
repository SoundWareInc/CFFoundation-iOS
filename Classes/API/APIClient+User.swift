//
//  APIClient+User.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {

    static func signUp<T: CFUserProtocol>(email: String, username: String, password: String, userType: T.Type, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        let parameters =  ["email" : email, "password" : password, "username" : username]
        request(route: "/users/signup", method: .post, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    getCurrentUser(userType: userType, completionHandler: completionHandler)
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func signIn<T: CFUserProtocol>(email: String, password: String, userType: T.Type, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        let parameters =  ["email" : email, "password" : password]
        request(route: "/users/signin", method: .post, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    getCurrentUser(userType: userType, completionHandler: completionHandler)
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func getCurrentUser<T: CFUserProtocol>(userType: T.Type, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        if let id = APISession.currentUser?._id {
            getItem(type: userType, from: "/users/" + id, completionHandler: completionHandler)
        } else {
            completionHandler(.failure(.init(message: "No user id")))
        }
    }
    
    static func getUser<T: CFUserProtocol>(by id: String, userType: T.Type, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        getItem(type: userType, from: "/users/" + id, completionHandler: completionHandler)
    }
}

