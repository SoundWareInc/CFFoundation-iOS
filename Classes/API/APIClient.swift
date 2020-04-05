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
    static func request(route: String, method: HTTPMethod, parameters: Parameters? = nil) -> Future<Data,NetworkError> {
        return Future { promise in
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
                            promise(.failure(.init(statusCode: statusCode, message: statusCodeMessage + "No data in response")))
                            return
                        }
                        do {
                            let networkError = try JSONDecoder().decode(ResponseValidationError.self, from: data)
                            if var error = networkError.details.first {
                                error.responseData = data
                                promise(.failure(error))
                            } else {
                                promise(.failure(.init(statusCode: statusCode, message: statusCodeMessage + "Error parsing ResponseValidationError", responseData: data)))
                            }
                        } catch {
                            do {
                                var networkError = try JSONDecoder().decode(ResponseError.self, from: data)
                                networkError.error.responseData = data
                                promise(.failure(networkError.error))
                            } catch {
                                do {
                                    let networkError = try JSONDecoder().decode(GenericResponseError.self, from: data)
                                    promise(.failure(.init(statusCode: statusCode, message: statusCodeMessage + networkError.error, responseData: data)))
                                } catch {
                                    promise(.success(data))
                                }
                            }
                        }
                    case .failure(let error):
                        promise(.failure(.init(statusCode: error.responseCode, message: statusCodeMessage + error.localizedDescription)))
                    }
            }
        }
    }
    
    static func getItem<T: Decodable>(
        responseType: T.Type,
        from route: String,
        parameters: Parameters? = nil) -> Future<T, NetworkError> {
        return Future { promise in
            _ = request(route: route, method: .get, parameters: parameters).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("finished")
                }
            }, receiveValue: { data in
                do {
                    let item = try JSONDecoder().decode(responseType.self, from: data)
                    promise(.success(item))
                } catch let error {
                    promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                }
            })
        }
    }
    
    static func getItems<T: Decodable>(
        responseType: [T].Type,
        from route: String,
        parameters: Parameters? = nil) -> Future<[T], NetworkError> {
        return Future { promise in
            _ = request(route: route, method: .get, parameters: parameters).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("finished")
                case .failure(let error):
                    promise(.failure(error))
                }
                }, receiveValue: { data in
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        promise(.success(item))
                    } catch let error {
                        promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                })
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
                _ = request(route: route, method: .post, parameters: params).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { data in
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        promise(.success(item))
                    } catch let error {
                        promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                })
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
                _ = request(route: route, method: .put, parameters: params).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        print("finished")
                    }
                }, receiveValue: { data in
                    do {
                        let item = try JSONDecoder().decode(responseType.self, from: data)
                        promise(.success(item))
                    } catch let error {
                        promise(.failure(.init(message: error.localizedDescription, responseData: data)))
                    }
                })
            } catch let error {
                promise(.failure(.init(message: error.localizedDescription)))
            }
        }
    }
    
    static func deleteItem(
        route: String) -> Future<String, NetworkError> {
        return Future { promise in
            _ = request(route: route, method: .delete).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("finished")
                }
            }, receiveValue: { data in
                promise(.success("deleted"))
            })
        };
    }
    
}
