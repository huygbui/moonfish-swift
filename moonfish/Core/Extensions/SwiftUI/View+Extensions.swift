import SwiftUI

extension View {
    func conditionalSafeAreaBottomPadding(_ length: CGFloat = 60) -> some View {
        modifier(ConditionalSafeAreaBottomPadding(60))
    }
}

struct ConditionalSafeAreaBottomPadding: ViewModifier {
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
