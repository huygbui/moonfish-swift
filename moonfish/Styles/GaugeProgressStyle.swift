//
//  GaugeProgressStyle.swift
//  moonfish
//
//  Created by Huy Bui on 10/5/25.
//

import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeWidth: CGFloat = 4
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        return GaugeProgress(fractionCompleted: fractionCompleted, strokeWidth: strokeWidth)
    }
}
