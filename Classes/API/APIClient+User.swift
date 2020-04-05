//
//  APIClient+User.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire
import Combine

extension APIClient {

    static func signUp<T: CFUserProtocol>(
        email: String,
        username: String,
        password: String,
        userType: T.Type) -> Future<T,NetworkError> {
        return Future { promise in
            let parameters =  ["email" : email, "password" : password, "username" : username]
            _ = request(
            route: "/users/signup",
            method: .post,
            parameters: parameters).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("finished")
                }
            }, receiveValue: { data in
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    _ = getCurrentUser(userType: userType).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                        
                    }, receiveValue: { data in
                        promise(.success(data))
                    })
                } catch let error {
                    promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                }
            })
        }
    }
    
    static func signIn<T: CFUserProtocol>(email: String, password: String, userType: T.Type) -> Future<T,NetworkError> {
        return Future { promise in
            let parameters =  ["email" : email, "password" : password]
            _ = request(route: "/users/signin", method: .post, parameters: parameters).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("finished")
                }
            }, receiveValue: { data in
                do {
                    let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                    APISession.token = response.token
                    APISession.currentUser = response.user
                    _ = getCurrentUser(userType: userType).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                        switch result {
                        case .failure(let error):
                            promise(.failure(error))
                        case .finished:
                            print("finished")
                        }
                    }, receiveValue: { data in
                        promise(.success(data))
                    })
                } catch let error {
                    promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                }
            })
        }
    }
    
    static func getCurrentUser<T: CFUserProtocol>(
        userType: T.Type) -> Future<T,NetworkError> {
        return Future { promise in
            if let id = APISession.currentUser?._id {
                _ = getItem(
                    responseType: userType,
                    from: "/users/" + id).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                        switch result {
                        case .finished:
                            print("finished")
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { data in
                        promise(.success(data))
                    })
            } else {
                promise(.failure(.init(message: "No user id")))
            }
        }
    }
    
    static func getUser<T: CFUserProtocol>(
        by id: String,
        userType: T.Type) -> Future<T,NetworkError> {
        return Future { promise in
            _ = getItem(
            responseType: userType,
            from: "/users/" + id).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("finished")
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { data in
                promise(.success(data))
            })
        }
    }
}

