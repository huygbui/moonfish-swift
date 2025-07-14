//
//  NetworkConfiguration.swift
//  moonfish
//
//  Created by Huy Bui on 15/7/25.
//

import Foundation

struct NetworkConfig {
    let baseURL: URL
    
    static let `default` = NetworkConfig(
        baseURL: AppConfig.shared.baseURL
    )
}
