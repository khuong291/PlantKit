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
    @State private var selectedDate = Date()
    @State private var showPlantPicker = false
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
            let allReminders = getAllReminders()
            
            if allReminders.isEmpty {
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    improvedEmptyStateView
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    // Weekly calendar view
                    weeklyCalendarView
                    
                    // Grouped reminders by care type
                    groupedRemindersSection(reminders: allReminders)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
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
        .sheet(isPresented: $showPlantPicker) {
            PlantPickerView(plants: Array(plants)) { selectedPlant in
                if let plantDetails = plantDetails(from: selectedPlant) {
                    myPlantsRouter.navigate(to: .plantDetails(plantDetails))
                }
                showPlantPicker = false
            }
        }
    }
    
    private var improvedEmptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("ic-calendar")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack(spacing: 8) {
                Text("No care reminders yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Add reminders to your plants to keep track of their care schedule")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Quick action to add reminders
            Button(action: {
                showPlantPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Reminder")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(25)
            }
            Spacer()
        }
    }
    
    private func getAllReminders() -> [CareReminder] {
        var allReminders: [CareReminder] = []
        for plant in plants {
            let plantReminders = careReminderManager.getRemindersForPlant(plant)
            allReminders.append(contentsOf: plantReminders) // Remove the filter to show all reminders
        }
        return allReminders.sorted { ($0.nextDueDate ?? Date()) < ($1.nextDueDate ?? Date()) }
    }
    
    private func groupedRemindersSection(reminders: [CareReminder]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Only show reminders for selected date
            let selectedDateReminders = getRemindersForDate(selectedDate)
            
            if selectedDateReminders.isEmpty {
                // Calculate days until next task
                let futureReminders = reminders.compactMap { $0.nextDueDate }.filter { $0 > selectedDate }
                let daysUntilNextTask = futureReminders.map { Calendar.current.dateComponents([.day], from: selectedDate, to: $0).day ?? 0 }.min()
                VStack(spacing: 12) {
                    Image("no-task-illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 4)
                    Text("No task today")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    if let days = daysUntilNextTask, days > 0 {
                        Text("The next tasks are in \(days) days")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    } else {
                        Text("No upcoming tasks")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 180)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            } else {
                // Group reminders by care type for selected date
                let groupedReminders = getGroupedReminders(reminders: selectedDateReminders)
                
                LazyVStack(spacing: 12) {
                    ForEach(Array(ReminderType.allCases.enumerated()), id: \.element) { index, reminderType in
                        if let typeReminders = groupedReminders[reminderType], !typeReminders.isEmpty {
                            careTypeGroupView(reminderType: reminderType, reminders: typeReminders)
                        }
                    }
                }
            }
        }
    }
    
    private func getDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func getGroupedReminders(reminders: [CareReminder]) -> [ReminderType: [CareReminder]] {
        var grouped: [ReminderType: [CareReminder]] = [:]
        
        for reminder in reminders {
            guard let reminderTypeString = reminder.reminderType,
                  let reminderType = careReminderManager.getReminderType(from: reminderTypeString),
                  reminder.isEnabled else { continue }
            
            if grouped[reminderType] == nil {
                grouped[reminderType] = []
            }
            grouped[reminderType]?.append(reminder)
        }
        
        return grouped
    }
    
    private func careTypeGroupView(reminderType: ReminderType, reminders: [CareReminder]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with care type info
            HStack {
                Image(reminderType.icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(reminderType.title)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                let overdueCount = reminders.filter { reminder in
                    guard let nextDue = reminder.nextDueDate else { return false }
                    return nextDue < Date() && reminder.isEnabled
                }.count
                
                let todayCount = reminders.filter { reminder in
                    guard let nextDue = reminder.nextDueDate else { return false }
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
                    let reminderDay = calendar.startOfDay(for: nextDue)
                    return reminderDay >= today && reminderDay < tomorrow && reminder.isEnabled
                }.count
                
                if overdueCount > 0 {
                    Text("\(overdueCount) overdue")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                } else if todayCount > 0 {
                    Text("\(todayCount) today")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Reminders list
            LazyVStack(spacing: 6) {
                ForEach(Array(reminders.sorted { ($0.nextDueDate ?? Date()) < ($1.nextDueDate ?? Date()) }.enumerated()), id: \.element.id) { index, reminder in
                    GroupedReminderCard(
                        reminder: reminder,
                        reminderType: reminderType,
                        onMenuTap: {
                            selectedReminder = reminder
                            showActionSheet = true
                        }
                    )
                    
                    // Add divider if not the last item
                    if index < reminders.count - 1 {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
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
    
    // MARK: - Weekly Calendar View
    
    private var weeklyCalendarView: some View {
        VStack(spacing: 4) {
            // Week navigation
            HStack {
                Button(action: {
                    selectedDayOffset -= 7
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                let weekStart = getWeekStart(for: Date().addingTimeInterval(TimeInterval(selectedDayOffset * 24 * 60 * 60)))
                let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
                
                Text("\(formatDateRange(from: weekStart, to: weekEnd))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    selectedDayOffset += 7
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 10)
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar dates
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let weekStart = getWeekStart(for: Date().addingTimeInterval(TimeInterval(selectedDayOffset * 24 * 60 * 60)))
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart)!
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isToday = Calendar.current.isDateInToday(date)
                    let hasReminders = getRemindersForDate(date).count > 0
                    
                    Button(action: {
                        selectedDate = date
                    }) {
                        ZStack {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.green : Color.clear)
                                .frame(width: 40, height: 40)
                            
                            // Day number
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .green : .primary))
                            
                            // Today indicator (top right overlay)
                            if hasReminders {
                                VStack {
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 12, height: 12)
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: 40, height: 40)
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func getWeekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func getRemindersForDate(_ date: Date) -> [CareReminder] {
        let allReminders = getAllReminders()
        return allReminders.filter { reminder in
            guard let nextDue = reminder.nextDueDate else { return false }
            return Calendar.current.isDate(nextDue, inSameDayAs: date) && reminder.isEnabled
        }
    }
    
    private func selectedDateRemindersSection(reminders: [CareReminder]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(formatSelectedDate(selectedDate))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(reminders, id: \.id) { reminder in
                    selectedDateReminderRow(reminder: reminder)
                }
            }
        }
    }
    
    private func selectedDateReminderRow(reminder: CareReminder) -> some View {
        HStack(spacing: 12) {
            // Plant image
            if let plantImageData = reminder.plant?.plantImage,
               let uiImage = UIImage(data: plantImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.plant?.commonName ?? "Unknown Plant")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(getReminderEmoji(for: reminder))
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Text(getReminderTypeText(for: reminder))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button("Complete") {
                careReminderManager.markReminderCompleted(reminder)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

struct GroupedReminderCard: View {
    let reminder: CareReminder
    let reminderType: ReminderType
    let onMenuTap: () -> Void
    
    @EnvironmentObject private var reminderManager: CareReminderManager
    @EnvironmentObject var myPlantsRouter: Router<ContentRoute>
    
    private var isOverdue: Bool {
        guard let nextDue = reminder.nextDueDate else { return false }
        return nextDue < Date() && reminder.isEnabled
    }
    
    private var isCompletedToday: Bool {
        reminderManager.isCompletionMarked(for: reminder, date: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Plant image (clickable for navigation)
            Button {
                if let plant = reminder.plant,
                   let plantDetails = plantDetails(from: plant) {
                    myPlantsRouter.navigate(to: .plantDetails(plantDetails))
                }
            } label: {
                if let plant = reminder.plant,
                   let plantImageData = plant.plantImage,
                   let uiImage = UIImage(data: plantImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemSymbol: .leafFill)
                                .foregroundColor(.gray)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Reminder info
            VStack(alignment: .leading, spacing: 4) {
                // Line 1: Plant name
                Text(reminder.plant?.commonName ?? "Unknown Plant")
                    .font(.system(size: 17).weight(.semibold))
                    .foregroundColor(.primary)
                
                // Line 2: Time only
                if let nextDue = reminder.nextDueDate {
                    Text(formatTimeOnly(nextDue))
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                // Line 3: Status
                Text(getReminderStatus())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(getStatusColor())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getStatusColor().opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Menu button
            Button(action: onMenuTap) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
    
    private func getReminderStatus() -> String {
        if isCompletedToday {
            return "Completed"
        }
        
        guard let nextDue = reminder.nextDueDate else { return "Unknown" }
        let now = Date()
        let timeInterval = nextDue.timeIntervalSince(now)
        
        if timeInterval < 0 {
            // Overdue
            let days = Int(abs(timeInterval) / (24 * 60 * 60))
            if days == 0 {
                return "Overdue"
            } else if days == 1 {
                return "Overdue 1 day"
            } else {
                return "Overdue \(days) days"
            }
        } else {
            // Upcoming
            let days = Int(timeInterval / (24 * 60 * 60))
            if days == 0 {
                return "Due today"
            } else if days == 1 {
                return "Due tomorrow"
            } else {
                return "Due in \(days) days"
            }
        }
    }
    
    private func getStatusColor() -> Color {
        if isCompletedToday {
            return .green
        }
        
        guard let nextDue = reminder.nextDueDate else { return .gray }
        let now = Date()
        let timeInterval = nextDue.timeIntervalSince(now)
        
        if timeInterval < 0 {
            return .red // Overdue
        } else if timeInterval < 24 * 60 * 60 {
            return .orange // Due within 24 hours
        } else {
            return .blue // Due later
        }
    }
    
    private func plantDetails(from plant: Plant) -> PlantDetails? {
        // Create PlantDetails from Core Data Plant
        let id = UUID(uuidString: plant.id ?? "") ?? UUID()
        let plantImageData = plant.plantImage ?? Data()
        let commonName = plant.commonName ?? "Unknown Plant"
        let scientificName = plant.scientificName ?? ""
        let plantDescription = plant.plantDescription ?? ""
        
        // Create General info
        let general = PlantDetails.General(
            habitat: plant.generalHabitat ?? "",
            originCountries: (plant.generalOriginCountries ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            environmentalBenefits: (plant.generalEnvironmentalBenefits ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )
        
        // Create Physical info
        let physical = PlantDetails.Physical(
            height: plant.physicalHeight ?? "",
            crownDiameter: plant.physicalCrownDiameter ?? "",
            form: plant.physicalForm ?? ""
        )
        
        // Create Development info
        let development = PlantDetails.Development(
            matureHeightTime: plant.developmentMatureHeightTime ?? "",
            growthSpeed: Int(plant.developmentGrowthSpeed),
            propagationMethods: (plant.developmentPropagationMethods ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            cycle: plant.developmentCycle ?? ""
        )
        
        // Create Conditions
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
            plantImageData: plantImageData,
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
            createdAt: plant.createdAt ?? Date(),
            updatedAt: plant.updatedAt ?? Date()
        )
    }
}

struct PlantPickerView: View {
    let plants: [Plant]
    let onPlantSelected: (Plant) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appScreenBackgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                if plants.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No plants yet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Scan a plant first to add reminders")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(plants, id: \.id) { plant in
                                PlantPickerRow(plant: plant) {
                                    onPlantSelected(plant)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlantPickerRow: View {
    let plant: Plant
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Plant image
                if let plantImageData = plant.plantImage,
                   let uiImage = UIImage(data: plantImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                // Plant info
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.commonName ?? "Unknown Plant")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let scientificName = plant.scientificName, !scientificName.isEmpty {
                        Text(scientificName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyPlantsScreen()
        .environmentObject(IdentifierManager())
        .environmentObject(CareReminderManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
}
