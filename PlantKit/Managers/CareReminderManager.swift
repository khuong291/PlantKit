//
//  CareReminderManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import Foundation
import CoreData
import UserNotifications
import SwiftUI

enum ReminderType: String, CaseIterable {
    case watering = "watering"
    case fertilizing = "fertilizing"
    case repotting = "repotting"
    case pruning = "pruning"
    
    var title: String {
        switch self {
        case .watering: return "Watering"
        case .fertilizing: return "Fertilizing"
        case .repotting: return "Repotting"
        case .pruning: return "Pruning"
        }
    }
    
    var icon: String {
        switch self {
        case .watering: return "ic-watering"
        case .fertilizing: return "ic-fertilizing"
        case .repotting: return "ic-repotting"
        case .pruning: return "ic-pruning"
        }
    }
    
    var color: Color {
        switch self {
        case .watering: return .blue
        case .fertilizing: return .green
        case .repotting: return .brown
        case .pruning: return .purple
        }
    }
    
    var defaultFrequency: Int16 {
        switch self {
        case .watering: return 7
        case .fertilizing: return 30
        case .repotting: return 365
        case .pruning: return 90
        }
    }
}

enum RepeatType: String, CaseIterable {
    case days = "days"
    case weeks = "weeks"
    case months = "months"
    
    var title: String {
        switch self {
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        }
    }
}

class CareReminderManager: ObservableObject {
    static let shared = CareReminderManager()
    
    @Published var reminders: [CareReminder] = []
    @Published var dailyCompletions: [CareCompletion] = []
    
    private init() {}
    
    // Loads reminders for all plants and updates the reminders array
    func loadAllReminders() {
        let context = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<CareReminder> = CareReminder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CareReminder.nextDueDate, ascending: true)]
        do {
            reminders = try context.fetch(fetchRequest)
        } catch {
            print("Error loading all reminders: \(error)")
            reminders = []
        }
    }
    
    func createReminder(
        for plant: Plant,
        type: ReminderType,
        frequency: Int16,
        repeatType: RepeatType,
        reminderTime: Date,
        notes: String? = nil
    ) {
        let context = CoreDataManager.shared.viewContext
        
        let reminder = CareReminder(context: context)
        reminder.id = UUID().uuidString
        reminder.title = "\(type.title) \(plant.commonName ?? "Plant")"
        reminder.reminderType = type.rawValue
        reminder.frequency = frequency
        reminder.repeatType = repeatType.rawValue
        reminder.reminderTime = reminderTime
        reminder.notes = notes
        reminder.isEnabled = true
        reminder.createdAt = Date()
        reminder.updatedAt = Date()
        
        // Calculate next due date based on repeat type
        let nextDueDate = calculateNextDueDate(frequency: frequency, repeatType: repeatType, reminderTime: reminderTime)
        reminder.nextDueDate = nextDueDate
        reminder.plant = plant
        
        do {
            try context.save()
            scheduleNotification(for: reminder)
            loadAllReminders()
        } catch {
            print("Error creating reminder: \(error)")
        }
    }
    
    private func calculateNextDueDate(frequency: Int16, repeatType: RepeatType, reminderTime: Date) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the time components from reminderTime
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Start with today's date
        var nextDate = calendar.startOfDay(for: now)
        
        // Add the time components
        nextDate = calendar.date(bySettingHour: timeComponents.hour ?? 9, minute: timeComponents.minute ?? 0, second: 0, of: nextDate) ?? nextDate
        
        // If the time has already passed today, calculate the next occurrence
        if nextDate <= now {
            switch repeatType {
            case .days:
                nextDate = calendar.date(byAdding: .day, value: Int(frequency), to: nextDate) ?? nextDate
            case .weeks:
                nextDate = calendar.date(byAdding: .weekOfYear, value: Int(frequency), to: nextDate) ?? nextDate
            case .months:
                nextDate = calendar.date(byAdding: .month, value: Int(frequency), to: nextDate) ?? nextDate
            }
        }
        
        return nextDate
    }
    
    func updateReminder(_ reminder: CareReminder, frequency: Int16, repeatType: RepeatType, reminderTime: Date, notes: String?, isEnabled: Bool) {
        let context = CoreDataManager.shared.viewContext
        
        reminder.frequency = frequency
        reminder.repeatType = repeatType.rawValue
        reminder.reminderTime = reminderTime
        reminder.notes = notes
        reminder.isEnabled = isEnabled
        reminder.updatedAt = Date()
        
        if isEnabled {
            let nextDueDate = calculateNextDueDate(frequency: frequency, repeatType: repeatType, reminderTime: reminderTime)
            reminder.nextDueDate = nextDueDate
        }
        
        do {
            try context.save()
            if isEnabled {
                scheduleNotification(for: reminder)
            } else {
                cancelNotification(for: reminder)
            }
            loadAllReminders()
        } catch {
            print("Error updating reminder: \(error)")
        }
    }
    
    func markReminderCompleted(_ reminder: CareReminder) {
        let context = CoreDataManager.shared.viewContext
        
        reminder.lastCompleted = Date()
        
        // Calculate next due date based on current reminder settings
        if let repeatTypeString = reminder.repeatType,
           let repeatType = RepeatType(rawValue: repeatTypeString),
           let reminderTime = reminder.reminderTime {
            let nextDueDate = calculateNextDueDate(frequency: reminder.frequency, repeatType: repeatType, reminderTime: reminderTime)
            reminder.nextDueDate = nextDueDate
        } else {
            // Fallback to old calculation
            reminder.nextDueDate = Date().addingTimeInterval(TimeInterval(reminder.frequency * 24 * 60 * 60))
        }
        
        reminder.updatedAt = Date()
        
        // Also mark daily completion for today
        markDailyCompletion(for: reminder, date: Date())
        
        do {
            try context.save()
            scheduleNotification(for: reminder)
            loadAllReminders()
        } catch {
            print("Error marking reminder completed: \(error)")
        }
    }
    
    func deleteReminder(_ reminder: CareReminder) {
        let context = CoreDataManager.shared.viewContext
        
        cancelNotification(for: reminder)
        context.delete(reminder)
        
        do {
            try context.save()
            loadAllReminders()
        } catch {
            print("Error deleting reminder: \(error)")
        }
    }
    
    func loadReminders(for plant: Plant?) {
        guard let plant = plant else { return }
        
        let context = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<CareReminder> = CareReminder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "plant == %@", plant)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CareReminder.nextDueDate, ascending: true)]
        
        do {
            reminders = try context.fetch(fetchRequest)
        } catch {
            print("Error loading reminders: \(error)")
            reminders = []
        }
    }
    
    private func scheduleNotification(for reminder: CareReminder) {
        guard reminder.isEnabled else { return }
        guard let nextDueDate = reminder.nextDueDate else { return }
        
        let content = UNMutableNotificationContent()
        
        // Get emoji, title, and body based on reminder type
        let (imageName, title, body) = getNotificationContent(for: reminder)
        content.title = title
        
        // No subtitle needed - keep it clean and simple
        
        // Use custom notes if available, otherwise use the enhanced body
        var finalBody = body
        
        if let notes = reminder.notes, !notes.isEmpty {
            finalBody += "\n\nYour notes: \(notes)"
        }
        
        content.body = finalBody
        
        // Add category for better organization
        content.categoryIdentifier = "PLANT_CARE_REMINDER"
        content.sound = .default
        
        // Check if the notification should fire immediately (within the next minute)
        let now = Date()
        let timeInterval = nextDueDate.timeIntervalSince(now)
        
        if timeInterval <= 60 && timeInterval > 0 {
            // Schedule for immediate delivery (within the next minute)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: reminder.id ?? UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling immediate notification: \(error)")
                } else {
                    print("Scheduled immediate notification for \(reminder.title ?? "reminder") in \(timeInterval) seconds")
                }
            }
        } else {
            // Schedule for the specific date/time
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDueDate),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: reminder.id ?? UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Scheduled notification for \(reminder.title ?? "reminder") at \(nextDueDate)")
                }
            }
        }
    }
    
    private func cancelNotification(for reminder: CareReminder) {
        guard let id = reminder.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Request permission
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("Notification permission granted")
                            self.setupNotificationCategories()
                        } else if let error = error {
                            print("Notification permission error: \(error)")
                        } else {
                            print("Notification permission denied")
                        }
                    }
                }
            case .denied:
                // Permission denied, could show alert to go to settings
                print("Notification permission denied - user needs to enable in Settings")
            case .authorized:
                print("Notification permission already granted")
                self.setupNotificationCategories()
            case .provisional:
                print("Provisional notification permission granted")
                self.setupNotificationCategories()
            case .ephemeral:
                print("Ephemeral notification permission granted")
                self.setupNotificationCategories()
            @unknown default:
                print("Unknown notification authorization status")
            }
        }
    }
    
    private func setupNotificationCategories() {
        // Create custom actions for plant care reminders
        let markCompletedAction = UNNotificationAction(
            identifier: "MARK_COMPLETED",
            title: "Mark as Done",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_1_HOUR",
            title: "Remind in 1 hour",
            options: []
        )
        
        let snoozeTomorrowAction = UNNotificationAction(
            identifier: "SNOOZE_TOMORROW",
            title: "Remind tomorrow",
            options: []
        )
        
        // Create the category
        let plantCareCategory = UNNotificationCategory(
            identifier: "PLANT_CARE_REMINDER",
            actions: [markCompletedAction, snoozeAction, snoozeTomorrowAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([plantCareCategory])
    }
    
    func getReminderType(from string: String) -> ReminderType? {
        return ReminderType.allCases.first { $0.rawValue == string }
    }
    
    func getRepeatType(from string: String) -> RepeatType? {
        return RepeatType.allCases.first { $0.rawValue == string }
    }
    
    private func getNotificationContent(for reminder: CareReminder) -> (imageName: String, title: String, body: String) {
        guard let reminderTypeString = reminder.reminderType,
              let reminderType = getReminderType(from: reminderTypeString) else {
            return ("ic-watering", reminder.title ?? "Plant Care Reminder", "Your plant needs some care!")
        }
        
        let plantName = reminder.plant?.commonName ?? "your plant"
        
        switch reminderType {
        case .watering:
            let motivationalMessages = [
                "Your \(plantName) is thirsty! Give it a refreshing drink to keep it happy and healthy.",
                "Time to hydrate your \(plantName)! A little water goes a long way in plant care.",
                "Your \(plantName) needs hydration! Watering regularly helps it grow strong and beautiful.",
                "Don't forget to water your \(plantName)! Consistent watering is key to plant success.",
                "Your \(plantName) is waiting for its drink! Proper hydration keeps leaves vibrant and healthy."
            ]
            let randomMessage = motivationalMessages.randomElement() ?? motivationalMessages[0]
            return ("ic-watering", "💧 Time to water \(plantName)", randomMessage)
            
        case .fertilizing:
            let motivationalMessages = [
                "Your \(plantName) needs nutrients! Fertilizing helps it grow bigger and stronger.",
                "Time to feed your \(plantName)! Nutrients are essential for healthy growth and vibrant leaves.",
                "Your \(plantName) is hungry for nutrients! Regular fertilizing promotes lush growth.",
                "Don't forget to fertilize your \(plantName)! Good nutrition leads to beautiful plants.",
                "Your \(plantName) needs a boost! Fertilizing gives it the energy to thrive and flourish."
            ]
            let randomMessage = motivationalMessages.randomElement() ?? motivationalMessages[0]
            return ("ic-fertilizing", "🌱 Time to fertilize \(plantName)", randomMessage)
            
        case .repotting:
            let motivationalMessages = [
                "Your \(plantName) needs more space! Repotting gives it room to grow and flourish.",
                "Time to give your \(plantName) a new home! Fresh soil and more space promote healthy growth.",
                "Your \(plantName) is ready for an upgrade! Repotting helps prevent root-bound issues.",
                "Don't forget to repot your \(plantName)! A bigger pot means bigger growth potential.",
                "Your \(plantName) needs a new pot! Repotting refreshes the soil and encourages new growth."
            ]
            let randomMessage = motivationalMessages.randomElement() ?? motivationalMessages[0]
            return ("ic-repotting", "🪴 Time to repot \(plantName)", randomMessage)
            
        case .pruning:
            let motivationalMessages = [
                "Your \(plantName) needs a trim! Pruning keeps it healthy and encourages new growth.",
                "Time to shape your \(plantName)! Pruning removes dead leaves and promotes bushier growth.",
                "Your \(plantName) is ready for a haircut! Pruning helps maintain its beautiful shape.",
                "Don't forget to prune your \(plantName)! Regular trimming keeps plants looking their best.",
                "Your \(plantName) needs some grooming! Pruning encourages healthy new shoots and leaves."
            ]
            let randomMessage = motivationalMessages.randomElement() ?? motivationalMessages[0]
            return ("ic-pruning", "✂️ Time to prune \(plantName)", randomMessage)
        }
    }
    
    func getRemindersForPlant(_ plant: Plant) -> [CareReminder] {
        return reminders.filter { $0.plant == plant }
    }
    
    func getOverdueReminders() -> [CareReminder] {
        return reminders.filter { reminder in
            guard let nextDue = reminder.nextDueDate else { return false }
            return nextDue < Date() && reminder.isEnabled
        }
    }
    
    func getUpcomingReminders(days: Int = 7) -> [CareReminder] {
        let futureDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
        return reminders.filter { reminder in
            guard let nextDue = reminder.nextDueDate else { return false }
            return nextDue > Date() && nextDue <= futureDate && reminder.isEnabled
        }
    }
    
    // MARK: - Daily Completion Tracking
    
    func markDailyCompletion(for reminder: CareReminder, date: Date = Date()) {
        let context = CoreDataManager.shared.viewContext
        
        // Check if completion already exists for this date
        if isCompletionMarked(for: reminder, date: date) {
            return
        }
        
        let completion = CareCompletion(context: context)
        completion.id = UUID().uuidString
        completion.completionDate = date
        completion.reminder = reminder
        completion.plant = reminder.plant
        completion.reminderType = reminder.reminderType
        completion.createdAt = Date()
        
        do {
            try context.save()
            loadDailyCompletions(for: reminder.plant)
        } catch {
            print("Error marking daily completion: \(error)")
        }
    }
    
    func unmarkDailyCompletion(for reminder: CareReminder, date: Date = Date()) {
        let context = CoreDataManager.shared.viewContext
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let fetchRequest: NSFetchRequest<CareCompletion> = CareCompletion.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "reminder == %@ AND completionDate >= %@ AND completionDate < %@", 
                                           reminder, 
                                           startOfDay as NSDate,
                                           endOfDay as NSDate)
        
        do {
            let completions = try context.fetch(fetchRequest)
            for completion in completions {
                context.delete(completion)
            }
            try context.save()
            loadDailyCompletions(for: reminder.plant)
        } catch {
            print("Error unmarking daily completion: \(error)")
        }
    }
    
    func isCompletionMarked(for reminder: CareReminder, date: Date = Date()) -> Bool {
        let context = CoreDataManager.shared.viewContext
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let fetchRequest: NSFetchRequest<CareCompletion> = CareCompletion.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "reminder == %@ AND completionDate >= %@ AND completionDate < %@", 
                                           reminder, 
                                           startOfDay as NSDate,
                                           endOfDay as NSDate)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking completion status: \(error)")
            return false
        }
    }
    
    func loadDailyCompletions(for plant: Plant?) {
        guard let plant = plant else { return }
        
        let context = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<CareCompletion> = CareCompletion.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "plant == %@", plant)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CareCompletion.completionDate, ascending: false)]
        
        do {
            dailyCompletions = try context.fetch(fetchRequest)
        } catch {
            print("Error loading daily completions: \(error)")
            dailyCompletions = []
        }
    }
    
    func getCompletionsForDate(_ date: Date, plant: Plant) -> [CareCompletion] {
        return dailyCompletions.filter { completion in
            guard let completionDate = completion.completionDate else { return false }
            return Calendar.current.isDate(completionDate, inSameDayAs: date)
        }
    }
    
    func getCompletionStreak(for reminder: CareReminder) -> Int {
        let context = CoreDataManager.shared.viewContext
        
        let fetchRequest: NSFetchRequest<CareCompletion> = CareCompletion.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "reminder == %@", reminder)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CareCompletion.completionDate, ascending: false)]
        
        do {
            let completions = try context.fetch(fetchRequest)
            let calendar = Calendar.current
            var streak = 0
            var currentDate = Date()
            
            for completion in completions {
                guard let completionDate = completion.completionDate else { continue }
                
                if calendar.isDate(completionDate, inSameDayAs: currentDate) {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else {
                    break
                }
            }
            
            return streak
        } catch {
            print("Error calculating completion streak: \(error)")
            return 0
        }
    }
    
    // Handle notification actions
    func handleNotificationAction(identifier: String, for reminderId: String) {
        guard let reminder = reminders.first(where: { $0.id == reminderId }) else { return }
        
        switch identifier {
        case "MARK_COMPLETED":
            markReminderCompleted(reminder)
        case "SNOOZE_1_HOUR":
            snoozeReminder(reminder, by: 1 * 60 * 60) // 1 hour
        case "SNOOZE_TOMORROW":
            snoozeReminder(reminder, by: 24 * 60 * 60) // 24 hours
        default:
            break
        }
    }
    
    func snoozeReminder(_ reminder: CareReminder, by timeInterval: TimeInterval) {
        let context = CoreDataManager.shared.viewContext
        
        // Calculate the new due date
        let newDueDate = Date().addingTimeInterval(timeInterval)
        
        // Check if this is a daily reminder and we're snoozing to tomorrow (24+ hours)
        if let repeatTypeString = reminder.repeatType,
           let repeatType = getRepeatType(from: repeatTypeString),
           repeatType == .days && reminder.frequency == 1 && timeInterval >= 24 * 60 * 60 {
            
            // For daily reminders snoozed to tomorrow, just mark today as completed
            // and let the normal schedule continue. This prevents duplicate reminders.
            markDailyCompletion(for: reminder, date: Date())
            return
        }
        
        // For all other cases, simply update the next due date
        reminder.nextDueDate = newDueDate
        reminder.updatedAt = Date()
        
        do {
            try context.save()
            scheduleNotification(for: reminder)
            loadAllReminders()
        } catch {
            print("Error snoozing reminder: \(error)")
        }
    }
    
    private func getCareTip(for reminderType: ReminderType, plantName: String) -> String {
        switch reminderType {
        case .watering:
            let tips = [
                "Check soil moisture with your finger before watering.",
                "Water until it drains from the bottom of the pot.",
                "Use room temperature water for best results.",
                "Water in the morning to allow leaves to dry during the day.",
                "Consider using a moisture meter for accuracy."
            ]
            return tips.randomElement() ?? tips[0]
            
        case .fertilizing:
            let tips = [
                "Dilute fertilizer to half strength for safety.",
                "Fertilize during the growing season (spring/summer).",
                "Avoid fertilizing newly repotted plants for 6 weeks.",
                "Use organic fertilizers for gentler feeding.",
                "Water thoroughly before applying fertilizer."
            ]
            return tips.randomElement() ?? tips[0]
            
        case .repotting:
            let tips = [
                "Choose a pot only 1-2 inches larger than current.",
                "Use fresh, well-draining potting mix.",
                "Repot in spring when plants are actively growing.",
                "Gently loosen roots before placing in new pot.",
                "Water thoroughly after repotting to settle soil."
            ]
            return tips.randomElement() ?? tips[0]
            
        case .pruning:
            let tips = [
                "Use clean, sharp scissors or pruning shears.",
                "Remove dead, yellow, or damaged leaves first.",
                "Prune just above a leaf node for new growth.",
                "Don't remove more than 1/3 of the plant at once.",
                "Prune in spring or early summer for best results."
            ]
            return tips.randomElement() ?? tips[0]
        }
    }
} 
