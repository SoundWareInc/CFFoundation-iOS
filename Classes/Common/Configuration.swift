//
//  Configuration.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
enum Configuration {
    enum API {
        static let HostURL = "localhost:3000"
        static let BaseURL = "http://" + HostURL
        static let BaseChatURL = "ws://" + HostURL
    }
}
