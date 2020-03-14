//
//  APIClient.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    static let session = Session()
    static func request(route: String, method: HTTPMethod, parameters: Parameters? = nil, completionHandler: @escaping (Result<Data,NetworkError>) -> Void) {
        var header: HTTPHeaders?
        if let token = APISession.customToken {
            header = HTTPHeaders(["Authorization" : "Bearer " + token])
        } else if let token = APISession.token {
            header = HTTPHeaders(["Authorization" : token])
        }
        guard let encodedRoute = (Configuration.API.BaseURL + route).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return  }
        session.request(encodedRoute, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: header).response { (data) in
            guard let data = data.data else {
                completionHandler(.failure(.init(message: "Bad Data")))
                return
            }
            do {
                let networkError = try JSONDecoder().decode(ResponseValidationError.self, from: data)
                if var error = networkError.details.first {
                    error.responseData = data
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.failure(.init(message: "Network Error", responseData: data)))
                }
            } catch {
                do {
                    var networkError = try JSONDecoder().decode(ResponseError.self, from: data)
                    networkError.error.responseData = data
                    completionHandler(.failure(networkError.error))
                } catch {
                    completionHandler(.success(data))
                }
            }
        }
    }
    
    static func getItem<T: Decodable>(
        responseType: T.Type,
        from route: String,
        parameters: Parameters? = nil,
        completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        request(route: route, method: .get, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(responseType.self, from: data)
                    completionHandler(.success(item))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription, responseData: data)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func getItems<T: Decodable>(
        responseType: [T].Type,
        from route: String,
        parameters: Parameters? = nil,
        completionHandler: @escaping (Result<[T], NetworkError>) -> Void) {
        request(route: route, method: .get, parameters: parameters) { (result) in
            switch result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(responseType.self, from: data)
                    completionHandler(.success(item))
                } catch let error {
                    completionHandler(.failure(.init(message: error.localizedDescription, responseData: data)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func postItem<T: Codable, Y: Decodable>(
        itemToPost: T,
        responseType: Y.Type,
        to route: String, completionHandler: @escaping (Result<Y, NetworkError>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(itemToPost)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            request(route: route, method: .post, parameters: params) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        completionHandler(.success(item))
                    } catch let error {
                        completionHandler(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        } catch let error {
            completionHandler(.failure(.init(message: error.localizedDescription)))
        }
    }
    
    static func putItem<T: Codable, Y: Decodable>(
        itemToPut: T,
        responseType: Y.Type,
        to route: String,
        completionHandler: @escaping (Result<Y, NetworkError>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(itemToPut)
            let params = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            request(route: route, method: .put, parameters: params) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        completionHandler(.success(item))
                    } catch let error {
                        completionHandler(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        } catch let error {
            completionHandler(.failure(.init(message: error.localizedDescription)))
        }
    }
    
    static func deleteItem(
        route: String,
        completionHandler: @escaping (Result<String, NetworkError>) -> Void) {
        request(route: route, method: .delete) { (result) in
            switch result {
            case .success(_):
                completionHandler(.success("deleted"))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}
