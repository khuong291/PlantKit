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
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        let side = min(imageWidth, imageHeight) * 0.9
        
        let originX = (imageWidth - side) / 2
        let originY = (imageHeight - side) / 2
        
        let cropRect = CGRect(x: originX, y: originY, width: side, height: side)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: UUID { UUID() } // ensures it triggers the fullScreenCover each time
}
