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
    
    var hoursMinutesCompact: String {
        let (hours, remainder) = Int(self).quotientAndRemainder(dividingBy: 3600)
        let minutes = remainder / 60
        
        return switch (hours, minutes) {
        case (0, 0): "0m"
        case (0, let m): "\(m)m"
        case (let h, 0): "\(h)h"
        case (let h, let m): "\(h)h\(m)m"
        }
    }
}

extension Date {
    var compact: String {
        self.formatted(Date.FormatStyle().year(.twoDigits).month().day())
    }
    
    var relative: String {
        self.formatted(Date.RelativeFormatStyle())
    }
}
