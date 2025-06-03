//
//  Router.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

final class Router<Routes: Routable>: RoutableObject, ObservableObject {
    typealias Destination = Routes

    @Published var stack: [Routes] = []
}

