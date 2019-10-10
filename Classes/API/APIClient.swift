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
            data.logString()
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
}
