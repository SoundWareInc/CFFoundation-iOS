//
//  Message.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

public struct Message: Codable {
    public var text: String?
    public var from: User?
    public var createdAt: Int?
}
