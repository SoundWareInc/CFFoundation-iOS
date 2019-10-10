//
//  APIClient+User.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    static func signUp(email: String, username: String, password: String, completionHandler: @escaping (Result<CFUserProtocol,NetworkError>) -> Void) {
        let parameters =  ["email" : email, "password" : password, "username" : username]
        request(route: "/users/signup", method: .post, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    completionHandler(.success(response.user))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func signIn(email: String, password: String, completionHandler: @escaping (Result<CFUserProtocol,NetworkError>) -> Void) {
        let parameters =  ["email" : email, "password" : password]
        request(route: "/users/signin", method: .post, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    completionHandler(.success(response.user))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func getUser(by id: String, completionHandler: @escaping (Result<CFUserProtocol,NetworkError>) -> Void) {
        request(route: "/users/" + id, method: .get) { (result) in
            switch result {
            case .success(let data):
                do {
                    let user = try JSONDecoder().decode(CFUser.self, from: data)
                    completionHandler(.success(user))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func getAllUsers(completionHandler: @escaping (Result<[CFUserProtocol],NetworkError>) -> Void) {
        request(route: "/users", method: .get) { (result) in
            switch result {
            case .success(let data):
                do {
                    let users = try JSONDecoder().decode([CFUser].self, from: data)
                    completionHandler(.success(users))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}

