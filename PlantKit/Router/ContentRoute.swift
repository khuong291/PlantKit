//
//  ContentRoute.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

enum ContentRoute: Routable, Equatable {
    case home
    case ask
    case conversation(String, PlantDetails?)
    case plantDetails(PlantDetails)
    case samplePlantDetails(PlantDetails, UIImage)
    case articleDetails(ArticleDetails)
    case diseaseCategoryDetail(DiseaseCategory, [DiseaseSymptom])

    static func == (lhs: ContentRoute, rhs: ContentRoute) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case (.ask, .ask): return true
        case let (.conversation(id1, _), .conversation(id2, _)): return id1 == id2
        case let (.plantDetails(d1), .plantDetails(d2)): return d1.id == d2.id
        case let (.samplePlantDetails(d1, _), .samplePlantDetails(d2, _)): return d1.id == d2.id
        case let (.articleDetails(a1), .articleDetails(a2)): return a1.id == a2.id
        case let (.diseaseCategoryDetail(cat1, syms1), .diseaseCategoryDetail(cat2, syms2)):
            return cat1 == cat2 && syms1.map(\.id) == syms2.map(\.id)
        default: return false
        }
    }

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
        case .articleDetails(let article):
            ArticleDetailsScreen(article: article)
        case .diseaseCategoryDetail(let category, let symptoms):
            DiseaseCategoryDetailView(category: category, symptoms: symptoms)
        }
    }
}
