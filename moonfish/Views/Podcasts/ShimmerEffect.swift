//
//  ShimmerEffect.swift
//  moonfish
//
//  Created by Huy Bui on 11/6/25.
//

import SwiftUI

struct ShimmerConfig {
    var tint: Color = Color(.systemBackground)
    var minOpacity: Double = 0.5
    var maxOpacity: Double = 0.75
    var duration: Double = 1.0
}

fileprivate struct ShimmerModifier: ViewModifier {
    let config: ShimmerConfig
    
    @State private var isAnimating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? config.maxOpacity : config.minOpacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: config.duration)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

// 3. A clean View extension to apply the effect easily
extension View {
    @ViewBuilder func shimmer(config: ShimmerConfig = .init()) -> some View {
        self
            .modifier(ShimmerModifier(config: config))
    }
}
