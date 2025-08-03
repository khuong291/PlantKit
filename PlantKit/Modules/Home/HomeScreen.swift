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

// MARK: - Home Remedy Model

struct HomeRemedy: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String
    let tag: String
    let description: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HomeRemedy, rhs: HomeRemedy) -> Bool {
        lhs.id == rhs.id
    }
}

let homeRemedies: [HomeRemedy] = [
    HomeRemedy(
        title: "Baking Soda Spray for Plant Fungal Problems",
        imageName: "baking-soda",
        tag: "Fungicide",
        description: "Natural solution for fungal issues on plants"
    ),
    HomeRemedy(
        title: "Homemade Garlic Fungus and Pest Control",
        imageName: "garlic-spray",
        tag: "Fungicide",
        description: "Effective natural pest and fungus deterrent"
    ),
    HomeRemedy(
        title: "Neem Oil Treatment for Pests",
        imageName: "neem-oil",
        tag: "Pesticide",
        description: "Organic pest control solution"
    ),
    HomeRemedy(
        title: "Epsom Salt for Plant Health",
        imageName: "epsom-salt",
        tag: "Fertilizer",
        description: "Natural magnesium supplement for plants"
    ),
    HomeRemedy(
        title: "Cinnamon Powder for Root Rot",
        imageName: "cinnamon-powder",
        tag: "Antifungal",
        description: "Natural antifungal treatment for root issues"
    )
]

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
    @State private var showReminderIndicator = false
    
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
                    if showReminderIndicator {
                        reminderTaskIndicator
                            .padding(.top, 16)
                    }
                    plantToolsView
                        .padding(.top, 16)
                    popularIndoorPlantsView
                        .padding(.top, 32)
                    popularOutdoorPlantsView
                        .padding(.top, 32)
                    homeRemediesView
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
        .onAppear {
            careReminderManager.loadAllReminders()
            showReminderIndicator = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showReminderIndicator = true
            }
            // Force-load plant images for today's due reminders
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let dueReminders = careReminderManager.reminders.filter { reminder in
                guard let due = reminder.nextDueDate else { return false }
                return due >= today && due < tomorrow && reminder.isEnabled
            }
            for reminder in dueReminders {
                _ = reminder.plant?.plantImage
            }
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
                LazyHStack(spacing: 8) {
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
                LazyHStack(spacing: 8) {
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
    
    private var homeRemediesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Home Remedies")
                .font(.system(size: 20))
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(homeRemedies) { remedy in
                        HomeRemedyCard(
                            title: remedy.title,
                            imageName: remedy.imageName,
                            tag: remedy.tag,
                            description: remedy.description,
                            onTap: {
                                Haptics.shared.play()
                                homeRouter.navigate(to: .homeRemedyDetail(remedy))
                            }
                        )
                    }
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
            guard reminder.isEnabled else { return false }
            
            // Check if this is a daily reminder (frequency = 1, repeatType = .days)
            if let repeatTypeString = reminder.repeatType,
               let repeatType = careReminderManager.getRepeatType(from: repeatTypeString),
               repeatType == .days && reminder.frequency == 1 {
                // For daily reminders, show them from today onwards (not past days)
                return true // Since we're checking for today specifically, daily reminders should show
            }
            
            // For non-daily reminders, only show them on their due date
            guard let due = reminder.nextDueDate else { return false }
            return due >= today && due < tomorrow
        }
        let count = dueReminders.count
        
        // Hide the indicator if there are no reminders for today
        if count == 0 {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            Button(action: {
                Haptics.shared.play()
                NotificationCenter.default.post(name: .switchToMyPlantsTab, object: nil)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.orange)
                    Text("You have \(count) task\(count > 1 ? "s" : "") today")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    if let plant = dueReminders.first?.plant,
                       let imageData = plant.plantImage, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        )
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

struct HomeRemedyCard: View {
    let title: String
    let imageName: String
    let tag: String
    let description: String
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            Haptics.shared.play()
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 140)
                        .clipped()
                    
                    // Tag overlay
                    Text(tag)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(6)
                        .padding(8)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 8)
                    .frame(height: 44, alignment: .topLeading)
            }
            .frame(width: 260)
            .background(Color.white)
            .cornerRadius(12)
            .clipped()
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct HomeRemedyDetailView: View {
    let remedy: HomeRemedy
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Header image
                    Image(remedy.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(height: 260)
                        .clipped()
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 0) {
                        Spacer().frame(height: 220)
                        VStack(alignment: .leading, spacing: 20) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 5)
                                .frame(maxWidth: .infinity)
                                .offset(y: -10)

                            Text(remedy.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Text(remedy.description)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)

                            remedyContent
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                        )
                    }
                }
            }
            .overlay(
                HStack {
                    Button(action: { 
                        Haptics.shared.play()
                        dismiss() 
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 44) // For safe area
                    Spacer()
                }, alignment: .topLeading
            )
        }
        .background(EnableSwipeBack())
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private var remedyContent: some View {
        switch remedy.imageName {
        case "baking-soda":
            VStack(alignment: .leading, spacing: 16) {
                Text("What you'll need:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("• 1 tablespoon baking soda\n• 1 gallon water\n• 1 teaspoon liquid soap\n• Spray bottle")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to make it:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("1. Mix 1 tablespoon of baking soda with 1 gallon of water\n2. Add 1 teaspoon of liquid soap as a surfactant\n3. Pour into a spray bottle\n4. Shake well before each use")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to use:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("• Spray affected plants thoroughly, covering both sides of leaves\n• Apply early in the morning or late afternoon\n• Reapply every 7-10 days or after rain\n• Test on a small area first")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("Tip:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Baking soda works best for powdery mildew and other fungal diseases. It's safe for most plants but avoid using on very young seedlings.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
        case "garlic-spray":
            VStack(alignment: .leading, spacing: 16) {
                Text("What you'll need:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("• 2-3 garlic cloves\n• 1 quart water\n• 1 teaspoon liquid soap\n• Blender or food processor\n• Spray bottle")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to make it:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("1. Crush 2-3 garlic cloves finely\n2. Add to 1 quart of water and let steep for 24 hours\n3. Strain the mixture and add 1 teaspoon liquid soap\n4. Pour into a spray bottle")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to use:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("• Spray on affected plants, covering all surfaces\n• Apply in the evening to avoid sun damage\n• Reapply every 3-5 days\n• Can be used as a preventive measure")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("Tip:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Garlic spray is effective against aphids, spider mites, and some fungal diseases. The strong odor also acts as a deterrent for many pests.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
        case "neem-oil":
            VStack(alignment: .leading, spacing: 16) {
                Text("What you'll need:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("• Pure neem oil\n• Warm water\n• Liquid soap\n• Spray bottle\n• Measuring spoons")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to make it:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("1. Mix 1 teaspoon neem oil with 1 quart warm water\n2. Add 1/4 teaspoon liquid soap as emulsifier\n3. Shake vigorously until well mixed\n4. Use immediately or store in refrigerator")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to use:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("• Spray thoroughly on affected plants\n• Apply in the evening to avoid leaf burn\n• Cover both sides of leaves\n• Reapply every 7-14 days")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("Tip:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Neem oil is most effective against soft-bodied insects like aphids, whiteflies, and spider mites. It also has antifungal properties.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
        case "epsom-salt":
            VStack(alignment: .leading, spacing: 16) {
                Text("What you'll need:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("• Epsom salt (magnesium sulfate)\n• Water\n• Measuring spoons\n• Watering can or spray bottle")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to make it:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("1. Dissolve 1 tablespoon Epsom salt in 1 gallon water\n2. For foliar spray: use 2 tablespoons per gallon\n3. Stir until completely dissolved\n4. Use immediately")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to use:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("• Water plants at the base with the solution\n• For foliar feeding, spray leaves lightly\n• Apply once per month during growing season\n• Avoid over-application")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("Tip:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Epsom salt provides magnesium and sulfur, essential nutrients for plant health. It's especially beneficial for tomatoes, peppers, and roses.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
        case "cinnamon-powder":
            VStack(alignment: .leading, spacing: 16) {
                Text("What you'll need:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("• Ground cinnamon powder\n• Small brush or cotton swab\n• Water (for cinnamon tea)\n• Spray bottle (optional)")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to make it:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                
                Text("1. For direct application: Use pure ground cinnamon\n2. For cinnamon tea: Steep 1 tablespoon in 1 cup hot water\n3. Let cool and strain\n4. Pour into spray bottle if using liquid form")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("How to use:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("• Dust cinnamon powder directly on affected areas\n• Apply to fresh cuts or wounds on plants\n• Use cinnamon tea as a soil drench\n• Reapply as needed")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text("Tip:")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Cinnamon is a natural antifungal that helps prevent damping off in seedlings and protects against root rot. It also deters some pests.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
        default:
            VStack(alignment: .leading, spacing: 16) {
                Text("Remedy Details")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("This home remedy helps with plant health and pest control. Follow the instructions carefully and always test on a small area first.")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
        }
    }
}
