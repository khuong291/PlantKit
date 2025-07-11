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
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var homeRouter: Router<ContentRoute>
    @ObservedObject var proManager: ProManager = .shared
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var plantName: String?
    @State private var isLoading = false
    @State private var searchText: String = ""
    @State private var showAllTools = false
    @State private var showHealthCheckCamera = false
    @State private var showLightMeterCamera = false
    @State private var showWaterMeter = false
    
    @StateObject private var healthCheckManager = HealthCheckManager()
    
    // Callback to open camera from MainTab
    var onOpenCamera: (() -> Void)?
    
    private let tools: [Tool] = [
        .init(title: "Plant Identifier", imageName: "ic-tool-plant"),
        .init(title: "Health Check", imageName: "ic-tool-health-check"),
        .init(title: "Light Meter", imageName: "ic-tool-light"),
        .init(title: "Water Meter", imageName: "ic-tool-water")
//        .init(title: "Ask Botanist", imageName: "ic-tool-ask"),
//        .init(title: "Mushroom Identifier", imageName: "ic-tool-mushroom"),
//        .init(title: "Insect Identifier", imageName: "ic-tool-insect"),
//        .init(title: "Bird Identifier", imageName: "ic-tool-bird")
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
                    if !proManager.hasPro {
                        freeTrialClaimSection
                            .padding(.top, 16)
                    }
                    plantToolsView
                        .padding(.top, 16)
                    popularIndoorPlantsView
                        .padding(.top, 32)
                    popularOutdoorPlantsView
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                    articleSuggestionsView
                        .padding(.bottom, 70)
//                    recentlyScannedView
//                        .padding(.top, 32)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.never)
        }
        .fullScreenCover(isPresented: $showHealthCheckCamera) {
            HealthCheckCameraView(dismissAction: { showHealthCheckCamera = false })
                .environmentObject(cameraManager)
                .environmentObject(healthCheckManager)
        }
        .fullScreenCover(isPresented: $showLightMeterCamera) {
            LightMeterCameraView(dismissAction: { showLightMeterCamera = false })
        }
        .sheet(isPresented: $showWaterMeter) {
//            DynamicHeightSheet(isPresented: $showWaterMeter) {
                WaterMeterView(isPresented: $showWaterMeter)
                    .presentationDetents([.height(540)])
//            }
        }
    }
    
    private var topBar: some View {
        HStack {
            if let city = locationManager.city {
                Label(city, systemImage: "location.fill")
                    .font(.system(size: 17))
            } else {
                Label("Locating...", systemImage: "location.fill")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Temperature Display
            if let temp = locationManager.temperature {
                HStack(spacing: 4) {
                    Image(systemName: locationManager.weatherIcon)
                        .foregroundColor(.orange)
                    Text("\(Int(temp))°C")
                        .font(.system(size: 17))
                        .monospacedDigit()
                }
                .transition(.opacity)
            } else if locationManager.isLoadingWeather {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Loading weather…")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "cloud")
                        .foregroundColor(.gray)
                    Text("Weather unavailable")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
            }
        }
    }
    
    private var freeTrialClaimSection: some View {
        Button {
            Haptics.shared.play()
            proManager.showUpgradeProIfNeeded()
        } label: {
            HStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    
                    // Unread indicator
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
                
                Text("Your free trial has not yet been claimed. Tap to claim.")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var popularIndoorPlantsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Indoor Plants")
                .font(.system(size: 20))
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PopularPlantCard(
                        name: "Monstera Deliciosa",
                        imageName: "monstera",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.monsteraDeliciosa, UIImage(named: "monstera")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Snake Plant",
                        imageName: "snake-plant",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.snakePlant, UIImage(named: "snake-plant")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Fiddle Leaf Fig",
                        imageName: "fiddle-leaf",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.fiddleLeafFig, UIImage(named: "fiddle-leaf")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Peace Lily",
                        imageName: "peace-lily",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.peaceLily, UIImage(named: "peace-lily")!))
                        }
                    )
                    PopularPlantCard(
                        name: "ZZ Plant",
                        imageName: "zz-plant",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.zzPlant, UIImage(named: "zz-plant")!))
                        }
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var popularOutdoorPlantsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Outdoor Plants")
                .font(.system(size: 20))
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PopularPlantCard(
                        name: "Hydrangea",
                        imageName: "hydrangea",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.hydrangea, UIImage(named: "hydrangea")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Japanese Maple",
                        imageName: "japanese-maple",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.japaneseMaple, UIImage(named: "japanese-maple")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Lavender",
                        imageName: "lavender",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.lavender, UIImage(named: "lavender")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Rose Bush",
                        imageName: "rose-bush",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.roseBush, UIImage(named: "rose-bush")!))
                        }
                    )
                    PopularPlantCard(
                        name: "Boxwood",
                        imageName: "boxwood",
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .samplePlantDetails(SamplePlantData.boxwood, UIImage(named: "boxwood")!))
                        }
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var plantToolsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Tools")
                .font(.system(size: 22))
                .bold()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: itemsPerRow), spacing: verticalSpacing) {
                ForEach(visibleTools) { tool in
                    Button {
                        Haptics.shared.play()
                        if tool.title == "Health Check" {
                            if proManager.hasPro {
                                showHealthCheckCamera = true
                            } else {
                                proManager.showUpgradeProIfNeeded()
                            }
                        }
                        if tool.title == "Light Meter" {
                            showLightMeterCamera = true
                        }
                        if tool.title == "Water Meter" {
                            showWaterMeter = true
                        }
                        if tool.title == "Plant Identifier" {
                            if proManager.hasPro {
                                onOpenCamera?()
                            } else {
                                proManager.showUpgradeProIfNeeded()
                            }
                        }
                        // Add other tool actions here if needed
                    } label: {
                        PlantToolCardView(title: tool.title, imageName: tool.imageName)
                    }
                    .buttonStyle(CardButtonStyle())
                }
            }

//            Button(action: {
//                Haptics.shared.play()
//                withAnimation(.easeInOut(duration: 0.3)) {
//                    showAllTools.toggle()
//                }
//            }) {
//                Text(showAllTools ? "Show Less" : "Show More")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundStyle(.primary)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 52)
//                    .background(Color.white)
//                    .cornerRadius(12)
//            }
//            .buttonStyle(CardButtonStyle())
        }
    }
    
    // MARK: - Article Suggestions Section
    private var articleSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.system(size: 22))
                .bold()
                .padding(.bottom, 4)
            VStack(spacing: 16) {
                ForEach(ArticleDetails.sampleArticles) { article in
                    ArticleSuggestionCard(
                        category: article.category,
                        title: article.title,
                        imageName: article.imageName,
                        readingMinutes: article.readingMinutes,
                        onTap: {
                            Haptics.shared.play()
                            homeRouter.navigate(to: .articleDetails(article))
                        }
                    )
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
                        .font(.system(size: 20))
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
    let onTap: (() -> Void)?
    
    init(name: String, imageName: String, onTap: (() -> Void)? = nil) {
        self.name = name
        self.imageName = imageName
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            Haptics.shared.play()
            onTap?()
        }) {
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
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding(16)
                }
            }
            .frame(width: 200, height: 250)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeScreen()
}

// Add ArticleSuggestionCard view
struct ArticleSuggestionCard: View {
    let category: String
    let title: String
    let imageName: String
    let readingMinutes: Int
    let onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(category)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                    Text("\(readingMinutes) min read")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(CardButtonStyle())
    }
}
