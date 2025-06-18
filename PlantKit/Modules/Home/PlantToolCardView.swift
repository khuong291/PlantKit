//
//  PlantToolCardView.swift
//  PlantKit
//
//  Created by Khuong Pham on 6/6/25.
//

import SwiftUI

struct Tool: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct PlantToolCardView: View {
    let title: String
    let imageName: String

    var body: some View {
        VStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.green)

            Text(title)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    PlantToolCardView(title: "Plant Identifier", imageName: "ic-tool-plant")
}
