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
    @State private var selectedDayOffset = 0
    @State private var showActionSheet = false
    @State private var selectedReminder: CareReminder?
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
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Plants").tag(0)
                    Text("Reminders").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .onChange(of: selectedTab) { newValue in
                    if newValue == 1 {
                        careReminderManager.loadAllReminders()
                    }
                }
                
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
            careReminderManager.loadAllReminders()
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
            careReminderManager.loadDailyCompletions(for: plant)
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
            // Overdue - show exact time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Overdue at \(formatter.string(from: nextDueDate))"
        } else {
            // Upcoming
            let days = Int(timeInterval / (24 * 60 * 60))
            let hours = Int((timeInterval.truncatingRemainder(dividingBy: 24 * 60 * 60)) / (60 * 60))
            let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 60 * 60)) / 60)
            
            if days == 0 {
                if hours == 0 {
                    if minutes <= 1 {
                        return "Due now"
                    } else {
                        return "Due in \(minutes) minutes"
                    }
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
            return "ic-watering"
        }
        
        switch reminderType {
        case .watering: return "ic-watering"
        case .fertilizing: return "ic-fertilizing"
        case .repotting: return "ic-repotting"
        case .pruning: return "ic-pruning"
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
                    remindersEmptyView
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                } else {
                    weeklyOverviewBar(reminders: allReminders)
                    let selectedDayReminders = getRemindersForSelectedDay(reminders: allReminders)
                    if selectedDayReminders.isEmpty {
                        selectedDayEmptyView
                            .padding(.top, 50)
                    } else {
                        remindersListView(reminders: selectedDayReminders)
                    }
                }
                Spacer()
                    .frame(height: 40)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .confirmationDialog("Reminder Actions", isPresented: $showActionSheet) {
            if let reminder = selectedReminder {
                Button("Mark as Done") {
                    careReminderManager.markReminderCompleted(reminder)
                }
                
                Button("Remind in 1 hour") {
                    careReminderManager.snoozeReminder(reminder, by: 1 * 60 * 60)
                }
                
                Button("Remind tomorrow") {
                    careReminderManager.snoozeReminder(reminder, by: 24 * 60 * 60)
                }
                
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            if let reminder = selectedReminder {
                Text("Choose an action for \(reminder.plant?.commonName ?? "this reminder")")
            }
        }
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
                HStack(spacing: 16) {
                    // Plant image and info (clickable for navigation)
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
                                    Image(getReminderEmoji(for: reminder)).resizable().frame(width: 16, height: 16)
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
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Menu button
                    Button(action: {
                        selectedReminder = reminder
                        showActionSheet = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(getReminderColor(for: reminder).opacity(0.3), lineWidth: 2)
                )
                .contextMenu {
                    Button(action: {
                        careReminderManager.markReminderCompleted(reminder)
                    }) {
                        Label("Mark as Done", systemImage: "checkmark.circle.fill")
                    }
                    
                    Button(action: {
                        careReminderManager.snoozeReminder(reminder, by: 1 * 60 * 60) // 1 hour
                    }) {
                        Label("Remind in 1 hour", systemImage: "clock")
                    }
                    
                    Button(action: {
                        careReminderManager.snoozeReminder(reminder, by: 24 * 60 * 60) // 24 hours
                    }) {
                        Label("Remind tomorrow", systemImage: "calendar")
                    }
                }
            }
        }
    }
    
    private func weeklyOverviewBar(reminders: [CareReminder]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 18).weight(.semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let dayData = getDayData(for: dayOffset, reminders: reminders)
                    Button {
                        selectedDayOffset = dayOffset
                    } label: {
                        VStack(spacing: 4) {
                            // Day name
                            Text(dayData.dayName)
                                .font(.system(size: 10).weight(.medium))
                                .foregroundColor(dayData.isSelected ? .white : .secondary)
                            
                            // Day number
                            Text("\(dayData.dayNumber)")
                                .font(.system(size: 14).weight(.semibold))
                                .foregroundColor(dayData.isSelected ? .white : (dayData.isToday ? .white : .primary))
                            
                            // Reminder count
                            if dayData.reminderCount > 0 {
                                Text("\(dayData.reminderCount)")
                                    .font(.system(size: 10).weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(dayData.priorityColor)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getDayBackgroundColor(dayData: dayData))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func getDayData(for dayOffset: Int, reminders: [CareReminder]) -> (dayName: String, dayNumber: Int, reminderCount: Int, isToday: Bool, isSelected: Bool, priorityColor: Color) {
        let calendar = Calendar.current
        let today = Date()
        let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
        
        let dayName = getDayName(for: targetDate)
        let dayNumber = calendar.component(.day, from: targetDate)
        let isToday = calendar.isDate(targetDate, inSameDayAs: today)
        let isSelected = dayOffset == selectedDayOffset
        
        // Count reminders for this day
        let dayReminders = reminders.filter { reminder in
            guard let dueDate = reminder.nextDueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: targetDate)
        }
        
        let reminderCount = dayReminders.count
        
        // Determine priority color based on most urgent reminder
        let priorityColor: Color
        if reminderCount == 0 {
            priorityColor = .clear
        } else {
            let mostUrgentReminder = dayReminders.min { reminder1, reminder2 in
                let date1 = reminder1.nextDueDate ?? Date()
                let date2 = reminder2.nextDueDate ?? Date()
                return date1 < date2
            }
            priorityColor = getReminderColor(for: mostUrgentReminder ?? dayReminders[0])
        }
        
        return (dayName: dayName, dayNumber: dayNumber, reminderCount: reminderCount, isToday: isToday, isSelected: isSelected, priorityColor: priorityColor)
    }
    
    private func getDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func getDayBackgroundColor(dayData: (dayName: String, dayNumber: Int, reminderCount: Int, isToday: Bool, isSelected: Bool, priorityColor: Color)) -> Color {
        if dayData.isSelected {
            return .blue
        } else if dayData.isToday {
            return .blue.opacity(0.7)
        } else {
            return .white
        }
    }
    
    private func getRemindersForSelectedDay(reminders: [CareReminder]) -> [CareReminder] {
        let calendar = Calendar.current
        let today = Date()
        let selectedDate = calendar.date(byAdding: .day, value: selectedDayOffset, to: today) ?? today
        
        return reminders.filter { reminder in
            guard let dueDate = reminder.nextDueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }.sorted { ($0.nextDueDate ?? Date()) < ($1.nextDueDate ?? Date()) }
    }
    
    private var selectedDayEmptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .calendar)
                .font(.system(size: 28))
                .foregroundStyle(.blue)
            Text("No reminders for \(getSelectedDayName())")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Tap another day to see reminders")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getSelectedDayName() -> String {
        let calendar = Calendar.current
        let today = Date()
        let selectedDate = calendar.date(byAdding: .day, value: selectedDayOffset, to: today) ?? today
        return getDayName(for: selectedDate)
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
                            Text(details.commonName)
                                .font(.system(size: 17).weight(.semibold))
                            
                            Text(details.scientificName)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            Text(details.createdAt, style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
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
