//
//  APIClient.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Alamofire
import Combine

class APIClient {
    static let session = Session()
    static func request(route: String, method: HTTPMethod, parameters: Parameters? = nil, completionHandler: @escaping (Result<Data,NetworkError>) -> Void) {
        var header: HTTPHeaders?
        if let token = APISession.customToken {
            header = HTTPHeaders(["Authorization" : "Bearer " + token])
        } else if let token = APISession.token {
            header = HTTPHeaders(["Authorization" : token])
        }
        guard let encodedRoute = (Configuration.API.BaseURL + route).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        session.request(encodedRoute, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: header)
            .response { (response) in
                let statusCode = response.response?.statusCode
                var statusCodeMessage = ""
                if let statusCode = response.response?.statusCode {
                    statusCodeMessage = "\(statusCode): "
                }
                switch response.result {
                case .success(let data):
                    guard let data = data else {
                        completionHandler(.failure(.init(statusCode: statusCode, message: statusCodeMessage + "No data in response")))
                        return
                    }
                    do {
                        let networkError = try JSONDecoder().decode(ResponseValidationError.self, from: data)
                        if var error = networkError.details.first {
                            error.responseData = data
                            completionHandler(.failure(error))
                        } else {
                            completionHandler(.failure(.init(statusCode: statusCode, message: statusCodeMessage + "Error parsing ResponseValidationError", responseData: data)))
                        }
                    } catch {
                        do {
                            var networkError = try JSONDecoder().decode(ResponseError.self, from: data)
                            networkError.error.responseData = data
                            completionHandler(.failure(networkError.error))
                        } catch {
                            do {
                                let networkError = try JSONDecoder().decode(GenericResponseError.self, from: data)
                                completionHandler(.failure(.init(statusCode: statusCode, message: statusCodeMessage + networkError.error, responseData: data)))
                            } catch {
                                completionHandler(.success(data))
                            }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(.init(statusCode: error.responseCode, message: statusCodeMessage + error.localizedDescription)))
                }
        }
    }

    
    static func getItem<T: Decodable>(
        responseType: T.Type,
        from route: String,
        parameters: Parameters? = nil) -> Future<T, NetworkError> {
        return Future { promise in
            request(route: route, method: .get, parameters: parameters) { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let data):
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        promise(.success(item))
                    } catch let error {
                        promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                }
            }
        }
    }
    
    static func getItems<T: Decodable>(
        responseType: [T].Type,
        from route: String,
        parameters: Parameters? = nil) -> Future<[T], NetworkError> {
        return Future { promise in
            request(route: route, method: .get, parameters: parameters) { result in
                switch result {
                case .success(let data):
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        promise(.success(item))
                    } catch let error {
                        promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    static func postItem<T: Codable, Y: Decodable>(
        itemToPost: T,
        responseType: Y.Type,
        to route: String) -> Future<Y, NetworkError> {
        return Future { promise in
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(itemToPost)
                let params = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
                request(route: route, method: .post, parameters: params) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let item = try JSONDecoder().decode(responseType.self, from: data)
                            promise(.success(item))
                        } catch let error {
                            promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            } catch let error {
                promise(.failure(.init(message: error.localizedDescription)))
            }
        }
    }
    
    static func putItem<T: Codable, Y: Decodable>(
        itemToPut: T,
        responseType: Y.Type,
        to route: String) -> Future<Y, NetworkError> {
        return Future { promise in
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(itemToPut)
                let params = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
                request(route: route, method: .put, parameters: params) { result in
                    switch result {
                    case .failure(let error):
                        promise(.failure(error))
                    case .success(let data):
                        do {
                            let item = try JSONDecoder().decode(responseType.self, from: data)
                            promise(.success(item))
                        } catch let error {
                            promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                        }
                    }
                }
            } catch let error {
                promise(.failure(.init(message: error.localizedDescription)))
            }
        }
    }
    
    static func deleteItem(
        route: String) -> Future<String, NetworkError> {
        return Future { promise in
            request(route: route, method: .delete) { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success:
                    promise(.success("deleted"))
                }
            }
        };
    }
}
