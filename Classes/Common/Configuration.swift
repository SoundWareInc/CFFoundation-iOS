//
//  Configuration.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
enum Configuration {
    enum API {
        static let BaseURL = "http://" + CFFoundation.shared.hostURL
        static let BaseChatURL = "ws://" + CFFoundation.shared.hostURL
    }
}
