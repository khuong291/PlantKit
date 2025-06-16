//
//  MyPlantsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI
import CoreData

struct MyPlantsScreen: View {
    @EnvironmentObject var identifierManager: IdentifierManager
    @State private var refreshID = UUID()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.scannedAt, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<Plant>
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("My Plants")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    if plants.isEmpty {
                        Spacer()
                        emptyView
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        listView
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 100)
            }
            .frame(maxWidth: .infinity)
        }
        .id(refreshID)
        .onAppear {
            refreshID = UUID()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .leafFill)
                .font(.title)
                .foregroundStyle(.green)
            Text("No plants yet. Scan a plant to add it here!")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var listView: some View {
        LazyVStack {
            ForEach(plants) { plant in
                HStack(spacing: 16) {
                    if let imageData = plant.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
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
                        Text(plant.commonName ?? "")
                            .font(.headline)
                        Text(plant.scientificName ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let scannedAt = plant.scannedAt {
                            Text(scannedAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    MyPlantsScreen()
        .environmentObject(IdentifierManager())
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
