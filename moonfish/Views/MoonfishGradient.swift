//
//  MoonfishGradient.swift
//  moonfish
//
//  Created by Huy Bui on 21/5/25.
//

import SwiftUI

struct MoonfishGradientView: View {
    let paleIridescentBlue = Color(red: 224/255, green: 245/255, blue: 255/255)
    let mutedTeal = Color(red: 120/255, green: 194/255, blue: 196/255)
    let deeperSeafoam = Color(red: 65/255, green: 111/255, blue: 118/255)
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.7], [0.5, 0.7], [1.0, 0.7],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
            ],
            colors: [
                paleIridescentBlue, paleIridescentBlue, paleIridescentBlue,
                mutedTeal, mutedTeal, mutedTeal,
                .black, .black, .black
            ]
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MoonfishGradientView()
}
