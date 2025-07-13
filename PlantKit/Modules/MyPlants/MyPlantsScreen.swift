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
    @EnvironmentObject var myPlantsRouter: Router<ContentRoute>
    @EnvironmentObject var careReminderManager: CareReminderManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshID = UUID()
    @State private var selectedTab = 0
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.scannedAt, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<Plant>
    @State private var plantDetailsList: [PlantDetails] = []
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Plants")
                        .font(.system(size: 34))
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Plants").tag(0)
                    Text("Reminders").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    plantsTab
                        .tag(0)
                    
                    remindersTab
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .id(refreshID)
        .onAppear {
            refreshID = UUID()
            updatePlantDetailsList()
            loadAllPlantReminders()
        }
        .onReceive(careReminderManager.$reminders) { _ in
            // Refresh the view when reminders are updated
            updatePlantDetailsList()
        }
    }
    
    private func updatePlantDetailsList() {
        plantDetailsList = plants.compactMap { plantDetails(from: $0) }
    }
    
    private func loadAllPlantReminders() {
        for plant in plants {
            careReminderManager.loadReminders(for: plant)
        }
    }
    
    private func getNextReminder(for plant: Plant) -> CareReminder? {
        let plantReminders = careReminderManager.getRemindersForPlant(plant)
        return plantReminders
            .filter { $0.isEnabled && ($0.nextDueDate ?? Date()) > Date() }
            .sorted { ($0.nextDueDate ?? Date()) < ($1.nextDueDate ?? Date()) }
            .first
    }
    
    private func getReminderDisplayText(for reminder: CareReminder) -> String {
        guard let nextDueDate = reminder.nextDueDate else { return "" }
        
        let now = Date()
        let timeInterval = nextDueDate.timeIntervalSince(now)
        
        if timeInterval < 0 {
            // Overdue
            let days = Int(abs(timeInterval) / (24 * 60 * 60))
            if days == 0 {
                return "Overdue today"
            } else if days == 1 {
                return "Overdue 1 day"
            } else {
                return "Overdue \(days) days"
            }
        } else {
            // Upcoming
            let days = Int(timeInterval / (24 * 60 * 60))
            let hours = Int((timeInterval.truncatingRemainder(dividingBy: 24 * 60 * 60)) / (60 * 60))
            
            if days == 0 {
                if hours == 0 {
                    return "Due now"
                } else if hours == 1 {
                    return "Due in 1 hour"
                } else {
                    return "Due in \(hours) hours"
                }
            } else if days == 1 {
                return "Due tomorrow"
            } else {
                return "Due in \(days) days"
            }
        }
    }
    
    private func getReminderEmoji(for reminder: CareReminder) -> String {
        guard let reminderTypeString = reminder.reminderType,
              let reminderType = careReminderManager.getReminderType(from: reminderTypeString) else {
            return "🌱"
        }
        
        switch reminderType {
        case .watering: return "💧"
        case .fertilizing: return "🌿"
        case .repotting: return "🪴"
        case .pruning: return "✂️"
        }
    }
    
    private func getReminderTypeText(for reminder: CareReminder) -> String {
        guard let reminderTypeString = reminder.reminderType,
              let reminderType = careReminderManager.getReminderType(from: reminderTypeString) else {
            return "Care"
        }
        
        switch reminderType {
        case .watering: return "Watering"
        case .fertilizing: return "Fertilizing"
        case .repotting: return "Repotting"
        case .pruning: return "Pruning"
        }
    }
    
    private func getReminderColor(for reminder: CareReminder) -> Color {
        guard let nextDueDate = reminder.nextDueDate else { return .gray }
        
        let now = Date()
        let timeInterval = nextDueDate.timeIntervalSince(now)
        
        if timeInterval < 0 {
            // Overdue - red
            return .red
        } else if timeInterval < 24 * 60 * 60 {
            // Due within 24 hours - orange
            return .orange
        } else if timeInterval < 7 * 24 * 60 * 60 {
            // Due within a week - blue
            return .blue
        } else {
            // Due later - green
            return .green
        }
    }
    
    private var remindersTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let allReminders = getAllReminders()
                if allReminders.isEmpty {
                    Spacer()
                    remindersEmptyView
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    remindersListView(reminders: allReminders)
                }
                Spacer()
                    .frame(height: 40)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 200)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var remindersEmptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .bellFill)
                .font(.system(size: 28))
                .foregroundStyle(.orange)
            Text("No care reminders yet")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Add reminders to your plants to see them here")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func getAllReminders() -> [CareReminder] {
        var allReminders: [CareReminder] = []
        for plant in plants {
            let plantReminders = careReminderManager.getRemindersForPlant(plant)
            allReminders.append(contentsOf: plantReminders.filter { $0.isEnabled })
        }
        return allReminders.sorted { ($0.nextDueDate ?? Date()) < ($1.nextDueDate ?? Date()) }
    }
    
    private func remindersListView(reminders: [CareReminder]) -> some View {
        LazyVStack {
            ForEach(reminders, id: \.id) { reminder in
                Button {
                    if let plant = reminder.plant,
                       let plantDetails = plantDetails(from: plant) {
                        myPlantsRouter.navigate(to: .plantDetails(plantDetails))
                    }
                } label: {
                    HStack(spacing: 16) {
                        // Plant image
                        if let plant = reminder.plant,
                           let plantImageData = plant.plantImage,
                           let uiImage = UIImage(data: plantImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .clipped()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemSymbol: .leafFill)
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Plant name and reminder type
                            HStack {
                                Text(reminder.plant?.commonName ?? "Unknown Plant")
                                    .font(.system(size: 16).weight(.semibold))
                                Spacer()
                                Text(getReminderEmoji(for: reminder))
                                    .font(.system(size: 16))
                            }
                            
                            // Reminder type and time
                            HStack {
                                Text(getReminderTypeText(for: reminder))
                                    .font(.system(size: 14).weight(.medium))
                                    .foregroundColor(getReminderColor(for: reminder))
                                Spacer()
                                Text(getReminderDisplayText(for: reminder))
                                    .font(.system(size: 12))
                                    .foregroundColor(getReminderColor(for: reminder))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(getReminderColor(for: reminder).opacity(0.3), lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .leafFill)
                .font(.system(size: 28))
                .foregroundStyle(.green)
            Text("No plants yet. Scan a plant to add it here!")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func plantDetails(from plant: Plant) -> PlantDetails? {
        // id is required as UUID
        guard let idString = plant.id, let id = UUID(uuidString: idString) else { return nil }
        guard let commonName = plant.commonName else { return nil }
        guard let scientificName = plant.scientificName else { return nil }
        guard let plantDescription = plant.plantDescription else { return nil }
        guard let createdAt = plant.createdAt else { return nil }
        guard let updatedAt = plant.updatedAt else { return nil }
        // General
        let general = PlantDetails.General(
            habitat: plant.generalHabitat ?? "",
            originCountries: (plant.generalOriginCountries ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            environmentalBenefits: (plant.generalEnvironmentalBenefits ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )
        // Physical
        let physical = PlantDetails.Physical(
            height: plant.physicalHeight ?? "",
            crownDiameter: plant.physicalCrownDiameter ?? "",
            form: plant.physicalForm ?? ""
        )
        // Development
        let development = PlantDetails.Development(
            matureHeightTime: plant.developmentMatureHeightTime ?? "",
            growthSpeed: Int(plant.developmentGrowthSpeed),
            propagationMethods: (plant.developmentPropagationMethods ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            cycle: plant.developmentCycle ?? ""
        )
        // Conditions
        var conditions: PlantDetails.Conditions? = nil
        let climaticHardinessZone = plant.climaticHardinessZone ?? ""
        let soilPhLabel = plant.soilPhLabel ?? ""
        let lightAmount = plant.lightAmount ?? ""
        if !climaticHardinessZone.isEmpty || !soilPhLabel.isEmpty || !lightAmount.isEmpty {
            var climatic: PlantDetails.Conditions.Climatic? = nil
            if !climaticHardinessZone.isEmpty {
                let hardinessZone = climaticHardinessZone.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                climatic = PlantDetails.Conditions.Climatic(
                    hardinessZone: hardinessZone,
                    minTemperature: plant.climaticMinTemperature,
                    temperatureRange: .init(lower: plant.climaticTemperatureLower, upper: plant.climaticTemperatureUpper),
                    idealTemperatureRange: .init(lower: plant.climaticIdealTemperatureLower, upper: plant.climaticIdealTemperatureUpper),
                    humidityRange: .init(lower: Int(plant.climaticHumidityLower), upper: Int(plant.climaticHumidityUpper)),
                    windResistance: plant.climaticWindResistance
                )
            }
            var soil: PlantDetails.Conditions.Soil? = nil
            let soilPhRange = plant.soilPhRange ?? ""
            if !soilPhRange.isEmpty {
                let phRange = soilPhRange.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                soil = PlantDetails.Conditions.Soil(
                    phRange: phRange,
                    phLabel: soilPhLabel,
                    types: (plant.soilTypes ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                )
            }
            var light: PlantDetails.Conditions.Light? = nil
            let lightType = plant.lightType ?? ""
            if !lightAmount.isEmpty && !lightType.isEmpty {
                light = PlantDetails.Conditions.Light(amount: lightAmount, type: lightType)
            }
            conditions = PlantDetails.Conditions(climatic: climatic, soil: soil, light: light)
        }
        return PlantDetails(
            id: id,
            plantImageData: plant.plantImage ?? Data(),
            commonName: commonName,
            scientificName: scientificName,
            plantDescription: plantDescription,
            general: general,
            physical: physical,
            development: development,
            conditions: conditions,
            toxicity: plant.toxicity,
            careGuideWatering: plant.careGuideWatering,
            careGuideFertilizing: plant.careGuideFertilizing,
            careGuidePruning: plant.careGuidePruning,
            careGuideRepotting: plant.careGuideRepotting,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private var plantsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if plantDetailsList.isEmpty {
                    Spacer()
                    emptyView
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    plantsListView
                }
                Spacer()
                    .frame(height: 40)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var plantsListView: some View {
        LazyVStack {
            ForEach(Array(plantDetailsList.enumerated()), id: \.element.id) { index, details in
                Button {
                    myPlantsRouter.navigate(to: .plantDetails(details))
                } label: {
                    HStack(spacing: 16) {
                        if let uiImage = UIImage(data: details.plantImageData) {
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
                            // Top row: Plant name and created date
                            HStack {
                                Text(details.commonName)
                                    .font(.system(size: 17).weight(.semibold))
                                Spacer()
                                Text(details.createdAt, style: .date)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Text(details.scientificName)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    MyPlantsScreen()
        .environmentObject(IdentifierManager())
        .environmentObject(CareReminderManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
