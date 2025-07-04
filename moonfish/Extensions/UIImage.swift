//
//  UIImage.swift
//  moonfish
//
//  Created by Huy Bui on 4/7/25.
//

import SwiftUI

extension UIImage {
    var averageColor: (red: Double, green: Double, blue: Double)? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let extent = ciImage.extent
        guard extent.size.width > 0 && extent.size.height > 0 else { return nil }
        
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        return (
            red: Double(bitmap[0]) / 255.0,
            green: Double(bitmap[1]) / 255.0,
            blue: Double(bitmap[2]) / 255.0
        )
    }
}
