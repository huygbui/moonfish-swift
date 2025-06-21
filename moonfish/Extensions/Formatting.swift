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

extension Date {
    var compact: String {
        self.formatted(Date.FormatStyle().year(.twoDigits).month().day())
    }
    
    var relative: String {
        self.formatted(Date.RelativeFormatStyle())
    }
}
