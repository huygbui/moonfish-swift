//
//  DownloadGaugeProgress.swift
//  moonfish
//
//  Created by Huy Bui on 23/6/25.
//

import SwiftUI

struct DownloadGaugeProgress: View {
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
    }
}

#Preview() {
    DownloadGaugeProgress(fractionCompleted: 0.5, strokeWidth: 6)
        .frame(width: 48, height: 48)
}
