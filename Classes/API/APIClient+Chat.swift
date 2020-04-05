//
//  APIClient+Chat.swift
//  ios-foundation
//
//  Created by Robert on 7/6/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Combine

extension APIClient {
    static func chatInvite(user: CFUserProtocol, to roomId: String) -> Future<String,NetworkError> {
        return Future { promise in
            _ = request(route: "/chat/" + roomId + "/invite/" + user._id!, method: .post).receive(on: DispatchQueue.main).sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    print("finished")
                }
            }, receiveValue: { data in
                promise(.success(roomId))
            })
        }
    }
}
