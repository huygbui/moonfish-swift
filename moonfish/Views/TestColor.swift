//
//  TestColor.swift
//  moonfish
//
//  Created by Huy Bui on 12/6/25.
//

import SwiftUI

struct RetroColor {
    // Enhanced retro palette with more aesthetic color combinations
    static func randomRetroColor() -> Color {
        // Carefully curated retro hues with better spacing
        // Warm sunset oranges, dusty roses, sage greens, vintage teals, golden yellows
        let hues: [Double] = [
            0.02,  // Deep coral/salmon
            0.06,  // Burnt orange
            0.12,  // Golden yellow
            0.15,  // Mustard yellow
            0.25,  // Olive/sage green
            0.45,  // Dusty teal
            0.52,  // Muted cyan
            0.58,  // Powder blue
            0.78,  // Lavender
            0.92,  // Dusty rose
            0.96   // Warm pink
        ]
        
        // More nuanced saturation levels for better harmony
        let saturations: [Double] = [0.35, 0.45, 0.55, 0.65]
        
        // Refined brightness levels for that perfect retro feel
        let brightnesses: [Double] = [0.65, 0.75, 0.85]
        
        let hue = hues.randomElement()!
        let saturation = saturations.randomElement()!
        let brightness = brightnesses.randomElement()!
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    // Alternative: Weighted random for more pleasing color distribution
    static func randomRetroColorWeighted() -> Color {
        // Favorite retro colors with higher probability
        let favoriteHues: [Double] = [0.06, 0.12, 0.25, 0.45, 0.92] // Orange, yellow, sage, teal, dusty rose
        let standardHues: [Double] = [0.02, 0.15, 0.52, 0.58, 0.78, 0.96]
        
        // 70% chance for favorite colors, 30% for others
        let usesFavorite = Double.random(in: 0...1) < 0.7
        let hues = usesFavorite ? favoriteHues : standardHues
        
        let saturations: [Double] = [0.4, 0.5, 0.6]
        let brightnesses: [Double] = [0.7, 0.8]
        
        let hue = hues.randomElement()!
        let saturation = saturations.randomElement()!
        let brightness = brightnesses.randomElement()!
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    // Preset retro colors for consistent branding
    static let retroPresets: [Color] = [
        Color(hue: 0.06, saturation: 0.55, brightness: 0.8),  // Burnt orange
        Color(hue: 0.12, saturation: 0.6, brightness: 0.85),  // Golden yellow
        Color(hue: 0.25, saturation: 0.4, brightness: 0.7),   // Sage green
        Color(hue: 0.45, saturation: 0.5, brightness: 0.75),  // Dusty teal
        Color(hue: 0.92, saturation: 0.45, brightness: 0.8),  // Dusty rose
        Color(hue: 0.78, saturation: 0.35, brightness: 0.85), // Soft lavender
        Color(hue: 0.02, saturation: 0.5, brightness: 0.75),  // Coral
        Color(hue: 0.15, saturation: 0.65, brightness: 0.7)   // Mustard
    ]
    
    static func randomRetroPreset() -> Color {
        return retroPresets.randomElement()!
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            ForEach(1..<10, id: \.self) { _ in
                Rectangle()
                    .fill(RetroColor.randomRetroPreset())
                    .frame(width: 200, height: 200)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ContentView()
}
