//
//  HomeScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import CoreData
import CoreLocation
import Combine

struct HomeScreen: View {
    @EnvironmentObject var identifierManager: IdentifierManager
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var plantName: String?
    @State private var isLoading = false
    @State private var searchText: String = ""
    @State private var showAllTools = false
    
    @StateObject private var locationManager = LocationManager()
    
    private let tools: [Tool] = [
        .init(title: "Plant Identifier", imageName: "ic-tool-plant"),
        .init(title: "Disease Identifier", imageName: "ic-tool-disease"),
        .init(title: "Light Meter", imageName: "ic-tool-light"),
        .init(title: "Water Meter", imageName: "ic-tool-water"),
        .init(title: "Ask Botanist", imageName: "ic-tool-ask"),
        .init(title: "Mushroom Identifier", imageName: "ic-tool-mushroom"),
        .init(title: "Insect Identifier", imageName: "ic-tool-insect"),
        .init(title: "Bird Identifier", imageName: "ic-tool-bird")
    ]
    
    private let itemsPerRow = 2
    private let verticalSpacing: CGFloat = 8
    
    private var visibleTools: [Tool] {
        showAllTools ? tools : Array(tools.prefix(4))
    }
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.top, 6)
                    searchView
                        .padding(.top, 16)
                    plantToolsView
                        .padding(.top, 32)
                    recentlyScannedView
                        .padding(.top, 32)
//                    content
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.never)
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private var topBar: some View {
        HStack {
            if let city = locationManager.city {
                Label(city, systemImage: "location.fill")
                    .font(.headline)
            } else {
                Label("Locating...", systemImage: "location.fill")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Temperature Display
            if let temp = locationManager.temperature {
                HStack(spacing: 4) {
                    Image(systemName: locationManager.weatherIcon)
                        .foregroundColor(.orange)
                    Text("\(Int(temp))°C")
                        .font(.headline)
                        .monospacedDigit()
                }
                .transition(.opacity)
            } else {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Fetching weather…")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var searchView: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            TextField("Search plants, flowers, trees...", text: $searchText)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private var plantToolsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Tools")
                .font(.title3)
                .bold()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: itemsPerRow), spacing: verticalSpacing) {
                ForEach(visibleTools) { tool in
                    PlantToolCardView(title: tool.title, imageName: tool.imageName)
                }
            }

            Button(action: {
                Haptics.shared.play()
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAllTools.toggle()
                }
            }) {
                Text(showAllTools ? "Show Less" : "Show More")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .buttonStyle(CardButtonStyle())
        }
    }
    
    private var recentlyScannedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recently Scanned")
                .font(.title3)
                .bold()
            
            if identifierManager.isLoading {
                shimmerRow()
            } else if identifierManager.recentScans.isEmpty {
                Text("No scans yet.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                ForEach(identifierManager.recentScans.prefix(4)) { plant in
                    HStack(spacing: 12) {
                        if let image = plant.image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                        }
                        VStack(alignment: .leading) {
                            Text(plant.name)
                                .font(.headline)
                            Text(plant.scannedAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    @ViewBuilder
    func shimmerRow() -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 12)
            }
            Spacer()
        }
        .padding(8)
        .redacted(reason: .placeholder)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(12)
                }
                
                if isLoading {
                    ProgressView("Identifying...")
                }
                
                if let name = plantName {
                    Text("🌿 This is likely: **\(name)**")
                        .font(.title2)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.appScreenBackgroundColor)
    }
}

#Preview {
    HomeScreen()
}
