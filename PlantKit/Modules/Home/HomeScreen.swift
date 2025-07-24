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

// MARK: - Disease Category Model

enum DiseaseCategory: String, CaseIterable, Identifiable, Hashable {
    case wholePlant = "Whole Plant"
    case leaves = "Leaves"
    case stems = "Stems"
    case flowers = "Flowers"
    case fruits = "Fruits"
    case pests = "Pests"
    var id: String { rawValue }
}

struct DiseaseSymptom: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let description: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DiseaseSymptom, rhs: DiseaseSymptom) -> Bool {
        lhs.id == rhs.id
    }
}

let diseaseSymptoms: [DiseaseCategory: [DiseaseSymptom]] = [
    .wholePlant: [
        DiseaseSymptom(imageName: "pale-plant", description: "The entire plant is getting pale, and the stems are lengthening."),
        DiseaseSymptom(imageName: "dried-herb", description: "Every part of the plant above the soil line has dried out. This is common in herbs."),
        DiseaseSymptom(imageName: "black-rotting", description: "The entire plant has turned black and is rotting from the center."),
        DiseaseSymptom(imageName: "dried-out", description: "The entire plant has dried out.")
    ],
    .leaves: [
        DiseaseSymptom(imageName: "leaves-yellow", description: "Leaves are turning yellow and dropping off."),
        DiseaseSymptom(imageName: "leaves-spots", description: "Spots or patches appearing on leaves."),
        DiseaseSymptom(imageName: "leaves-curl", description: "Leaves are curling or misshapen.")
    ],
    .stems: [
        DiseaseSymptom(imageName: "stem-black", description: "Stems are turning black or mushy."),
        DiseaseSymptom(imageName: "stem-lesion", description: "Lesions or cankers on stems."),
        DiseaseSymptom(imageName: "stem-crack", description: "Stems are cracking or splitting.")
    ],
    .flowers: [
        DiseaseSymptom(imageName: "flower-blight", description: "Flowers are wilting or developing spots."),
        DiseaseSymptom(imageName: "flower-drop", description: "Flowers are dropping prematurely.")
    ],
    .fruits: [
        DiseaseSymptom(imageName: "fruit-rot", description: "Fruits are rotting or developing mold."),
        DiseaseSymptom(imageName: "fruit-spot", description: "Spots or blemishes on fruit skin.")
    ],
    .pests: [
        DiseaseSymptom(imageName: "pest-aphid", description: "Small green or black insects on leaves/stems."),
        DiseaseSymptom(imageName: "pest-mite", description: "Fine webbing or tiny moving dots on leaves."),
        DiseaseSymptom(imageName: "pest-scale", description: "Brown or white bumps on stems/leaves.")
    ]
]



struct HomeScreen: View {
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var identifierManager: IdentifierManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var homeRouter: Router<ContentRoute>
    @ObservedObject var proManager: ProManager = .shared
    @EnvironmentObject var careReminderManager: CareReminderManager
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @Binding var mainTabSelectedTab: MainTab.Tab
    
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
    @State private var showDiseaseCategoryDetail = false
    @State private var selectedDiseaseCategory: DiseaseCategory? = nil
    
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
                    reminderTaskIndicator
                        .padding(.top, 16)
                    plantToolsView
                        .padding(.top, 16)
                    popularIndoorPlantsView
                        .padding(.top, 32)
                    popularOutdoorPlantsView
                        .padding(.top, 32)
                    commonPlantDiseasesView
                        .padding(.top, 32)
                        .padding(.bottom, 8)
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
                HStack(spacing: 8) {
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
                HStack(spacing: 8) {
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
    
    private var commonPlantDiseasesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common Plant Diseases")
                .font(.system(size: 20))
                .bold()

            // Calculate grid height based on screen width
            let screenWidth = UIScreen.main.bounds.width
            let totalSpacing: CGFloat = 8 * 2 // 2 gaps between 3 columns
            let horizontalPadding: CGFloat = 0 // No extra padding
            let cardWidth = (screenWidth - totalSpacing - horizontalPadding) / 3
            let cardHeight = cardWidth * 1.25
            let rowCount = Int(ceil(Double(DiseaseCategory.allCases.count) / 3.0))
            let gridHeight = CGFloat(rowCount) * cardHeight + CGFloat(rowCount - 1) * 8

            GeometryReader { geometry in
                let columns = [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ]
                let cardWidth = (geometry.size.width - totalSpacing - horizontalPadding) / 3
                let cardHeight = cardWidth * 1.25

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(DiseaseCategory.allCases) { category in
                        DiseaseCard(
                            title: category.rawValue,
                            imageName: "disease-\(category.rawValue.lowercased().replacingOccurrences(of: " ", with: "-"))",
                            onTap: {
                                Haptics.shared.play()
                                homeRouter.navigate(to: .diseaseCategoryDetail(category, diseaseSymptoms[category] ?? []))
                            },
                            width: cardWidth,
                            height: cardHeight
                        )
                    }
                }
                // No .padding(.horizontal)
            }
            .frame(height: gridHeight)
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
    
    private var reminderTaskIndicator: some View {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dueReminders = careReminderManager.reminders.filter { reminder in
            guard let due = reminder.nextDueDate else { return false }
            return due >= today && due < tomorrow && reminder.isEnabled
        }
        let count = dueReminders.count
        
        return Button(action: {
            Haptics.shared.play()
            NotificationCenter.default.post(name: .switchToMyPlantsTab, object: nil)
        }) {
            HStack(spacing: 12) {
                Image(systemName: count > 0 ? "bell.badge.fill" : "bell")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(count > 0 ? .orange : .gray)
                Text(count > 0 ? "You have \(count) task\(count > 1 ? "s" : "") today" : "No tasks today")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(count > 0 ? Color.orange.opacity(0.1) : Color.gray.opacity(0.08))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Article Suggestions Section
    private var articleSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gardening Tips")
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

extension Notification.Name {
    static let switchToMyPlantsTab = Notification.Name("SwitchToMyPlantsTab")
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
                        .frame(width: 140, height: 180)
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
                        .font(.system(size: 15).weight(.medium))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            .frame(width: 140, height: 180)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DiseaseCard: View {
    let title: String
    let imageName: String
    let onTap: (() -> Void)?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Button(action: {
            Haptics.shared.play()
            onTap?()
        }) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(16)
                
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: height * 0.33)
                .cornerRadius(16)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(8)
            }
            .frame(width: width, height: height)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
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
            Haptics.shared.play()
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
