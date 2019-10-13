//
//  APIClient+Chat.swift
//  ios-foundation
//
//  Created by Robert on 7/6/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

extension APIClient {
    static func chatInvite(user: CFUserProtocol, to roomId: String, completionHandler: @escaping (Result<String,NetworkError>) -> Void) {
        request(route: "/chat/" + roomId + "/invite/" + user._id!, method: .post) { (result) in
            switch result {
            case .success( _):
                completionHandler(.success(roomId))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
