import SwiftUI

extension View {
    func conditionalSafeAreaBottomPadding(_ length: CGFloat = 60) -> some View {
        modifier(ConditionalSafeAreaBottomPadding(60))
    }
}

fileprivate struct ConditionalSafeAreaBottomPadding: ViewModifier {
    let length: CGFloat
    
    init(_ length: CGFloat = 60) {
        self.length = length
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .safeAreaPadding(.bottom, length)
        }
    }
}

extension View {
    @ViewBuilder func shimmer(config: ShimmerConfig = .init()) -> some View {
        self
            .modifier(ShimmerModifier(config: config))
    }
}

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


