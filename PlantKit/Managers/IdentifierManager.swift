//
//  IdentifierManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import Combine
import CoreData

class IdentifierManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastPlantDetails: PlantDetails?
    @Published var myPlantsScreenID = UUID()
    private var cancellables = Set<AnyCancellable>()
    
    func identify(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        lastPlantDetails = nil
        
        PlantIdentifier.identify(image: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    completion(.failure(NSError(domain: "IdentifierManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Manager was deallocated"])))
                    return
                }
                self.isLoading = false
                
                switch result {
                case .success(let detailsFromAPI):
                    // Inject the captured image data
                    let capturedImageData = image.jpegData(compressionQuality: 0.8) ?? Data()
                    let plantDetails = PlantDetails(
                        id: detailsFromAPI.id,
                        plantImageData: capturedImageData,
                        commonName: detailsFromAPI.commonName,
                        scientificName: detailsFromAPI.scientificName,
                        plantDescription: detailsFromAPI.plantDescription,
                        general: detailsFromAPI.general,
                        physical: detailsFromAPI.physical,
                        development: detailsFromAPI.development,
                        conditions: detailsFromAPI.conditions,
                        toxicity: detailsFromAPI.toxicity,
                        careGuideWatering: detailsFromAPI.careGuideWatering,
                        careGuideFertilizing: detailsFromAPI.careGuideFertilizing,
                        careGuidePruning: detailsFromAPI.careGuidePruning,
                        careGuideRepotting: detailsFromAPI.careGuideRepotting,
                        createdAt: detailsFromAPI.createdAt,
                        updatedAt: detailsFromAPI.updatedAt
                    )
                    self.lastPlantDetails = plantDetails
                    // Save to CoreData
                    CoreDataManager.shared.savePlant(details: plantDetails)
                    self.myPlantsScreenID = UUID() // Trigger UI refresh
                    completion(.success(()))
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
}
