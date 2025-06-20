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
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var identifierManager: IdentifierManager
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var plantName: String?
    @State private var isLoading = false
    @State private var searchText: String = ""
    @State private var showAllTools = false
    @State private var showHealthCheckCamera = false
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var healthCheckManager = HealthCheckManager()
    
    private let tools: [Tool] = [
        .init(title: "Plant Identifier", imageName: "ic-tool-plant"),
        .init(title: "Health Check", imageName: "ic-tool-health-check"),
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
                    popularIndoorPlantsView
                        .padding(.top, 32)
                    popularOutdoorPlantsView
                        .padding(.top, 32)
                        .padding(.bottom, 70)
//                    recentlyScannedView
//                        .padding(.top, 32)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.never)
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .sheet(isPresented: $showHealthCheckCamera) {
            HealthCheckCameraView(dismissAction: { showHealthCheckCamera = false })
                .environmentObject(cameraManager)
                .environmentObject(healthCheckManager)
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
    
    private var popularIndoorPlantsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Indoor Plants")
                .font(.title3)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PopularPlantCard(
                        name: "Monstera Deliciosa",
                        imageName: "monstera"
                    )
                    PopularPlantCard(
                        name: "Snake Plant",
                        imageName: "snake-plant"
                    )
                    PopularPlantCard(
                        name: "Fiddle Leaf Fig",
                        imageName: "fiddle-leaf"
                    )
                    PopularPlantCard(
                        name: "Peace Lily",
                        imageName: "peace-lily"
                    )
                    PopularPlantCard(
                        name: "ZZ Plant",
                        imageName: "zz-plant"
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var popularOutdoorPlantsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Outdoor Plants")
                .font(.title3)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PopularPlantCard(
                        name: "Hydrangea",
                        imageName: "hydrangea"
                    )
                    PopularPlantCard(
                        name: "Japanese Maple",
                        imageName: "japanese-maple"
                    )
                    PopularPlantCard(
                        name: "Lavender",
                        imageName: "lavender"
                    )
                    PopularPlantCard(
                        name: "Rose Bush",
                        imageName: "rose-bush"
                    )
                    PopularPlantCard(
                        name: "Boxwood",
                        imageName: "boxwood"
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var plantToolsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Tools")
                .font(.title3)
                .bold()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: itemsPerRow), spacing: verticalSpacing) {
                ForEach(visibleTools) { tool in
                    Button {
                        if tool.title == "Health Check" {
                            showHealthCheckCamera = true
                        }
                        if tool.title == "Plant Identifier" {
                            ProManager.shared.showUpgradePro()
                        }
                        // Add other tool actions here if needed
                    } label: {
                        PlantToolCardView(title: tool.title, imageName: tool.imageName)
                    }
                    .buttonStyle(CardButtonStyle())
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
    
//    private var recentlyScannedView: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Recently Scanned")
//                .font(.title3)
//                .bold()
//            
//            VStack {
//                if identifierManager.isLoading {
//                    shimmerRow()
//                }
//                ForEach(identifierManager.recentScans) { plant in
//                    HStack(spacing: 12) {
//                        if let image = plant.image {
//                            Image(uiImage: image)
//                                .resizable()
//                                .frame(width: 80, height: 80)
//                                .cornerRadius(8)
//                                .clipped()
//                        }
//                        VStack(alignment: .leading) {
//                            Text(plant.name)
//                                .font(.headline)
//                            Text(plant.scannedAt, style: .time)
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(12)
//                }
//            }
//        }
//    }
    
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
        .padding()
        .redacted(reason: .placeholder)
        .background(Color.white)
        .cornerRadius(12)
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

struct PopularPlantCard: View {
    let name: String
    let imageName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 250)
                    .clipped()
                    .cornerRadius(16)
                
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
                .cornerRadius(16)
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(16)
            }
        }
        .frame(width: 200, height: 250)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HomeScreen()
}
