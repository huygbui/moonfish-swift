//
//  Duration+FormatStyle.swift
//  moonfish
//
//  Created by Huy Bui on 20/6/25.
//

import Foundation

extension Double {
    var hoursMinutes: String {
        Duration.seconds(self).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
