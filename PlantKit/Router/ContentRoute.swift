//
//  ContentRoute.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

enum ContentRoute: Routable {
    case home

    var body: some View {
        switch self {
        case .home:
            HomeScreen()
        }
    }
}
