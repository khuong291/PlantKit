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
    case conversation(UUID)
    case plantDetails(PlantDetails)

    var body: some View {
        switch self {
        case .home:
            HomeScreen()
        case .ask:
            AskScreen()
        case .conversation(let id):
            ConversationScreen(conversationId: id)
        case .plantDetails(let details):
            PlantDetailsScreen(
                plantDetails: details,
                capturedImage: UIImage(data: details.plantImageData),
                onSwitchTab: { _ in }
            )
        }
    }
}
