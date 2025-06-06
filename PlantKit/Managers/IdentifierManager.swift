//
//  IdentifierManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

class IdentifierManager: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recentScans: [ScannedPlant] = []
    
    func identify(image: UIImage) {
        isLoading = true
        errorMessage = nil
        capturedImage = image
        
        PlantIdentifier.identify(image: image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let plantName):
                    self.isLoading = false
                    self.saveScan(name: plantName, image: image)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func saveScan(name: String, image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return }
        let newScan = ScannedPlant(id: UUID(), name: name, scannedAt: Date(), imageData: data)
        recentScans.insert(newScan, at: 0) // Add to top
    }
}
