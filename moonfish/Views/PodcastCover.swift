//
//  Ascii.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI

struct PodcastCover: View {
    var pattern: String = """
0000000110000000
0000000110000000
0000001111000000
0000011111100000
0000111111111100
0000011111111000
0000001111110000
0000000111100000
"""
    var color: Color = .green
    
    private var attributedPattern: AttributedString {
        var result = AttributedString("")
        
        for char in pattern {
            var charString = AttributedString(String(char))
            charString.foregroundColor = char == "0" ? .white.opacity(0.25) : .white
            result.append(charString)
        }
        
        return result
    }
    
    var body: some View {
        Text(attributedPattern)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .minimumScaleFactor(0.25)
            .padding(32)
            .frame(width: 256, height: 256, alignment: .center)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue, Color.blue],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: .rect(cornerRadius: 32)
            )
    }
}

#Preview {
    let pattern = "0000001100000000\n0000011110000000\n0000111111000000\n0001111111100000\n0011000000011000\n0110000000001100\n0110000000001100\n0011111111111100"
    
    let color = Color.blue
    
    PodcastCover(pattern: pattern, color: color)
}
