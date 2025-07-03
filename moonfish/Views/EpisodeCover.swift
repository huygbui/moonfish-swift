//
//  Ascii.swift
//  moonfish
//
//  Created by Huy Bui on 18/6/25.
//

import SwiftUI

struct EpisodeCover: View {
    var pattern: String
    var color: Color = Color(.systemIndigo)
    var size: CGFloat = 128
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 8
    
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
            .padding(padding)
            .frame(width: size, height: size, alignment: .center)
            .background(
                LinearGradient(
                    colors: [color, color, color],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: .rect(cornerRadius: cornerRadius)
            )
    }
}

#Preview {
    let pattern = "0001111111111000\n0001000000000100\n0001000000000100\n0001000000000100\n0001000000000100\n0000101010101000\n0000010101010000\n0000001111110000"
    let color = Color(.systemIndigo)
    EpisodeCover(pattern: pattern, color: color)
}
