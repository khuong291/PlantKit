//
//  View+Sheet.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentHeightSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat = .zero

    private var contentHeightMeasurerView: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ContentHeightKey.self, value: geometry.size.height + 60)
        }
    }

    func body(content: Content) -> some View {
        content
            .background(contentHeightMeasurerView)
            .onPreferenceChange(ContentHeightKey.self) { newValue in
                contentHeight = newValue
            }
            .presentationDetents([.height(max(contentHeight, 450))])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
    }
}

private struct SafeAreaSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat = .zero

    private var contentHeightMeasurerView: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ContentHeightKey.self, value: geometry.size.height + 40)
        }
    }

    func body(content: Content) -> some View {
        content
            .background(contentHeightMeasurerView)
            .onPreferenceChange(ContentHeightKey.self) { newValue in
                contentHeight = newValue
            }
            .presentationDetents([.height(max(contentHeight, 400))])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

extension View {
  func adjustSheetHeightToContent() -> some View {
    self.modifier(ContentHeightSheetModifier())
  }
  
  func safeAreaSheet() -> some View {
    self.modifier(SafeAreaSheetModifier())
  }
} 
