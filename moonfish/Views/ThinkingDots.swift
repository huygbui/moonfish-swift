//
//  ThinkingDotsView.swift
//  moonfish
//
//  Created by Huy Bui on 27/4/25.
//

import SwiftUI

/// A view that displays an animated thinking indicator with three dots.
/// The dots subtly scale and fade in and out in sequence.
struct ThinkingDots: View {

    /// Configuration for the dots' appearance and animation.
    struct Configuration {
        var count: Int = 3
        var size: CGFloat = 8
        var spacing: CGFloat = 5
        var scaleFactor: CGFloat = 0.6
        var baseOpacity: Double = 0.5
        var animationDuration: Double = 0.6
        var color: Color = .secondary
    }

    let configuration: Configuration

    // Internal state to drive the continuous animation loop
    @State private var isAnimating: Bool = false

    // Convenience initializer for default configuration
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    // Initializer for quick color customization
    init(color: Color) {
        self.configuration = .init(color: color)
    }

    var body: some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0..<configuration.count, id: \.self) { index in
                Circle()
                    .frame(width: configuration.size, height: configuration.size)
                    // Use a ternary conditional directly within the modifiers
                    .scaleEffect(isAnimating ? 1.0 : configuration.scaleFactor)
                    .opacity(isAnimating ? 1.0 : configuration.baseOpacity)
                    .foregroundStyle(configuration.color) // More modern than .foregroundColor
                    .animation(
                        // Define the core animation properties
                        Animation.easeInOut(duration: configuration.animationDuration)
                                 .repeatForever(autoreverses: true)
                                 // Stagger animation start for each dot
                                 .delay(delay(for: index)),
                        // Animate specifically when `isAnimating` changes
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            // Start animation shortly after appearing.
            // No asyncAfter needed usually, SwiftUI handles this better now.
            // If glitches occur on complex views, it could be re-added, but start without.
            isAnimating = true
        }
        // Optional: Reset if needed, but often unnecessary if view presence is tied to loading state
        // .onDisappear {
        //     isAnimating = false
        // }
    }

    /// Calculates the animation delay for a specific dot index.
    private func delay(for index: Int) -> Double {
        configuration.animationDuration / Double(configuration.count) * Double(index)
    }
}

// MARK: - Preview

#Preview("Default") {
    VStack(spacing: 20) {
        Text("Thinking...")
        ThinkingDots()
    }
    .padding()
}

#Preview("Custom Color") {
    VStack(spacing: 20) {
        Text("Thinking (Blue)...")
        ThinkingDots(color: .blue)
    }
    .padding()
}

#Preview("Custom Configuration") {
    VStack(spacing: 20) {
        Text("Thinking (Larger, Faster, Green)...")
        ThinkingDots(configuration: .init(
            count: 4,
            size: 12,
            spacing: 8,
            animationDuration: 0.4,
            color: .green
        ))
    }
    .padding()
}
