//
//  IdentifierManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

class IdentifierManager: ObservableObject {
    @Published var identifiedPlantName: String?
    @Published var capturedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func identify(image: UIImage) {
        self.isLoading = true
        self.errorMessage = nil
        self.identifiedPlantName = nil
        self.capturedImage = image // Store the image for UI
        
        PlantIdentifier.identify(image: image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let plantName):
                    self.identifiedPlantName = plantName
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
