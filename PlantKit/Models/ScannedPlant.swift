//
//  ScannedPlant.swift
//  PlantKit
//
//  Created by Khuong Pham on 6/6/25.
//

import SwiftUI

struct ScannedPlant: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let scannedAt: Date
    let imageData: Data
    
    var image: UIImage? {
        UIImage(data: imageData)
    }
}
