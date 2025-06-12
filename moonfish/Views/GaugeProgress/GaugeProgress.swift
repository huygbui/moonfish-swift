//
//  GaugeProgressStyle.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI

struct GaugeProgress: View {
    var fractionCompleted: Double
    var strokeWidth: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .foregroundStyle(.tertiary)
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .foregroundStyle(.primary)
        }
        .padding(strokeWidth/2)
    }
}

#Preview() {
    GaugeProgress(fractionCompleted: 0.5, strokeWidth: 6)
        .frame(width: 48, height: 48)
}
