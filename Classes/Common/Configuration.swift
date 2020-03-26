//
//  Configuration.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
enum Configuration {
    enum API {
        static var BaseURL: String = {
            if CFFoundation.shared.hostURL.hasPrefix("http://") || CFFoundation.shared.hostURL.hasPrefix("https://") {
                return CFFoundation.shared.hostURL
            }
            return "http://" + CFFoundation.shared.hostURL
        }()
        static let BaseChatURL = "ws://" + CFFoundation.shared.hostURL
    }
}
