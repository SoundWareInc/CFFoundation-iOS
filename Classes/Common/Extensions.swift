//
//  Extensions.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
    func logString() {
        print(toString() ?? "Data not in string format")
    }
}
