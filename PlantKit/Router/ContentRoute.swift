//
//  ContentRoute.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

enum ContentRoute: Routable {
    case home
    case ask
    case conversation(String, PlantDetails?)
    case plantDetails(PlantDetails)
    case samplePlantDetails(PlantDetails, UIImage)

    var body: some View {
        switch self {
        case .home:
            HomeScreen()
        case .ask:
            AskScreen()
        case .conversation(let id, let plantDetails):
            ConversationScreen(conversationId: id, plantDetails: plantDetails)
        case .plantDetails(let details):
            PlantDetailsScreen(
                plantDetails: details,
                capturedImage: UIImage(data: details.plantImageData),
                isSamplePlant: false
            )
        case .samplePlantDetails(let details, let image):
            PlantDetailsScreen(
                plantDetails: details,
                capturedImage: image,
                isSamplePlant: true
            )
        }
    }
}
