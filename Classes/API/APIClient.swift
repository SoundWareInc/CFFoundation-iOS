//
//  APIClient.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire

public struct NetworkError: Error, Codable {
    var message: String?
}

class APIClient {
    static func request(route: String, method: HTTPMethod, parameters: Parameters? = nil, completionHandler: @escaping (Result<Data,NetworkError>) -> Void) {
        var header: HTTPHeaders?
        if let token = APISession.token {
            header = HTTPHeaders(["Authorization" : token])
        }
        AF.request(Configuration.API.BaseURL + route, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: header).response { (data) in
            guard let data = data.data else {
                completionHandler(.failure(.init(message: "Bad Data")))
                return
            }
            do {
                let networkError = try JSONDecoder().decode(ResponseValidationError.self, from: data)
                if let error = networkError.details.first {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(.init(message: "Network Error")))
                }
            } catch {
                completionHandler(.success(data))
            }
        }
    }
    
    static func getItem<T: Codable>(type: T.Type, from route: String, parameters: Parameters? = nil, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        request(route: route, method: .get, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(type.self, from: data)
                    completionHandler(.success(item))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func getItems<T: Codable>(type: [T].Type, from route: String, parameters: Parameters? = nil, completionHandler: @escaping (Result<[T],NetworkError>) -> Void) {
        request(route: route, method: .get, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(type.self, from: data)
                    completionHandler(.success(item))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func postItem<T: Codable>(itemToPost: T, type: T.Type, to route: String, completionHandler: @escaping (Result<T,NetworkError>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(itemToPost)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            request(route: route, method: .post, parameters: params) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let item = try JSONDecoder().decode(type.self, from: data)
                        completionHandler(.success(item))
                    } catch let error {
                        completionHandler(.failure(.init(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        } catch let error {
            completionHandler(.failure(.init(message: error.localizedDescription)))
        }
    }
}
