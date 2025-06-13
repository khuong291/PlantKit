//
//  MyPlantsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI

struct MyPlantsScreen: View {
    @EnvironmentObject var identifierManager: IdentifierManager
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            if identifierManager.recentScans.isEmpty {
                Text("No plants yet. Scan a plant to add it here!")
                    .foregroundColor(.gray)
                    .font(.title3)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(identifierManager.recentScans) { plant in
                            HStack(spacing: 16) {
                                if let image = plant.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(12)
                                        .clipped()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(plant.name)
                                        .font(.headline)
                                    Text(plant.scannedAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MyPlantsScreen().environmentObject(IdentifierManager())
}
