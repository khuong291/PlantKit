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
            .presentationDetents([.height(min(contentHeight, 650))])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DynamicHeightSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    @State private var sheetHeight: CGFloat = 400
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height + 40)
                }
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                withAnimation(.easeInOut(duration: 0.3)) {
                    sheetHeight = newHeight
                }
            }
            .presentationDetents([.height(max(sheetHeight, 400))])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

extension View {
  func adjustSheetHeightToContent() -> some View {
    self.modifier(ContentHeightSheetModifier())
  }
} 
