import Foundation

extension Date {
    var compact: String {
        self.formatted(Date.FormatStyle().year(.twoDigits).month().day())
    }
    
    var relative: String {
        self.formatted(Date.RelativeFormatStyle())
    }
}
