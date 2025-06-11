//
//  IdentifierManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

class IdentifierManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recentScans: [ScannedPlant] = []
    
    func identify(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Create a weak reference to self to avoid retain cycle
        PlantIdentifier.identify(image: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    completion(.failure(NSError(domain: "IdentifierManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Manager was deallocated"])))
                    return
                }
                
                self.isLoading = false
                
                switch result {
                case .success(let plantName):
                    self.saveScan(name: plantName, image: image)
                    completion(.success(()))
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
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
