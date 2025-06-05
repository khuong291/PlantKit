//
//  UIImage+ext.swift
//  PlantKit
//
//  Created by Khuong Pham on 5/6/25.
//

import SwiftUI

extension UIImage {
    func croppedToCenterSquare() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width) * 0.9
        let height = CGFloat(cgImage.height)
        
        let length = min(width, height)
        let originX = (width - length) / 2
        let originY = (height - length) / 2
        
        let cropRect = CGRect(x: originX, y: originY, width: length, height: length)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: UUID { UUID() } // ensures it triggers the fullScreenCover each time
}
