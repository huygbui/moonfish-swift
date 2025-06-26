//
//  ColorsSchemePreference.swift
//  moonfish
//
//  Created by Huy Bui on 26/6/25.
//

import SwiftUI

enum ColorSchemePreference: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case automatic = "automatic"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .automatic:
            return "Automatic"
        }
    }
    
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil // Follow system
        }
    }
}
