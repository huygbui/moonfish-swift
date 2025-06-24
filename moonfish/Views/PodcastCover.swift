//
//  Ascii.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI

struct PodcastCover: View {
    let pattern: String
    let color: Color
    
    var body: some View {
        Text(attributedPattern)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .minimumScaleFactor(0.25)
            .padding(32)
            .frame(width: 256, height: 256, alignment: .center)
            .background(color, in: .rect(cornerRadius: 16))
    }
    
    private var attributedPattern: AttributedString {
        var result = AttributedString("")
        
        for char in pattern {
            var charString = AttributedString(String(char))
            charString.foregroundColor = char == "0" ? .white.opacity(0.25) : .white
            result.append(charString)
        }
        
        return result
    }
}

#Preview {
    let pattern = """
0000000110000000
0000000110000000
0000001111000000
0000011111100000
0000111111111100
0000011111111000
0000001111110000
0000000111100000
"""
    
    let color = Color.accentColor
    
    PodcastCover(pattern: pattern, color: color)
}
