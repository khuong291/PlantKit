//
//  RoutingView.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

struct RoutingView<Root: View, Routes: Routable>: View {
    @Binding private var routes: [Routes]
    private let root: () -> Root

    /// Initializes a new instance of `RoutingView` with the specified navigation stack and root view.
    ///
    /// - Parameters:
    ///   - stack: A binding to an array of `Routes` indicating the current navigation stack.
    ///   - root: A closure that returns the root view of the navigation stack.
    init(
        stack: Binding<[Routes]>,
        @ViewBuilder root: @escaping () -> Root
    ) where Routes: Routable {
        self._routes = stack
        self.root = root
    }

    /// The body of the `RoutingView`. This view contains the navigation logic and view mapping based on the current state of the `routes` array.
    ///
    /// It uses a `NavigationStack` to present the root view and navigates to other views based on the `Routes` enum.
    var body: some View {
        NavigationStack(path: $routes) {
            root()
                .navigationDestination(for: Routes.self) { view in
                    view.body
                }
        }
    }
}
