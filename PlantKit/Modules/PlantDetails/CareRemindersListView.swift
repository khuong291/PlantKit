//
//  CareRemindersListView.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI
import CoreData

struct CareRemindersListView: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reminderManager: CareReminderManager
    @State private var showAddReminder = false
    @State private var selectedReminder: CareReminder?
    @State private var showEditReminder = false
    @State private var showDeleteAlert = false
    @State private var reminderToDelete: CareReminder?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appScreenBackgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                let plantReminders = reminderManager.reminders.filter { $0.plant == plant }
                if plantReminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .navigationTitle("Care Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddReminder = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showAddReminder) {
                CareReminderView(plant: plant, reminder: nil)
                    .environmentObject(reminderManager)
            }
            .sheet(isPresented: $showEditReminder) {
                if let reminder = selectedReminder {
                    CareReminderView(plant: plant, reminder: reminder)
                        .environmentObject(reminderManager)
                }
            }
            .alert("Delete Reminder", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let reminder = reminderToDelete {
                        reminderManager.deleteReminder(reminder)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this reminder? This action cannot be undone.")
            }
        }
        .onAppear {
            reminderManager.loadReminders(for: plant)
            reminderManager.loadDailyCompletions(for: plant)
            // Request notification permission when user opens reminders
            reminderManager.requestNotificationPermission()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image("ic-calendar")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            VStack(spacing: 8) {
                Text("No Care Reminders")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Set up reminders to help you take care of your \(plant.commonName ?? "plant")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showAddReminder = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Reminder")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(25)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var remindersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let plantReminders = reminderManager.reminders.filter { $0.plant == plant }
                ForEach(plantReminders, id: \.id) { reminder in
                    ReminderCard(
                        reminder: reminder,
                        onEdit: {
                            selectedReminder = reminder
                            showEditReminder = true
                        },
                        onComplete: {
                            reminderManager.markReminderCompleted(reminder)
                        },
                        onDelete: {
                            reminderToDelete = reminder
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct ReminderCard: View {
    let reminder: CareReminder
    let onEdit: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject private var reminderManager: CareReminderManager
    @State private var showDailyTracking = false
    @State private var showActionSheet = false
    
    private var reminderType: ReminderType? {
        reminderManager.getReminderType(from: reminder.reminderType ?? "")
    }
    
    private var isOverdue: Bool {
        guard let nextDue = reminder.nextDueDate else { return false }
        return nextDue < Date() && reminder.isEnabled
    }
    
    private var isUpcoming: Bool {
        guard let nextDue = reminder.nextDueDate else { return false }
        let futureDate = Date().addingTimeInterval(TimeInterval(7 * 24 * 60 * 60))
        return nextDue > Date() && nextDue <= futureDate && reminder.isEnabled
    }
    
    private var isCompletedToday: Bool {
        reminderManager.isCompletionMarked(for: reminder, date: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let type = reminderType {
                    Image(type.icon)
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(type.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reminder.title ?? "Reminder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let notes = reminder.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if !reminder.isEnabled {
                    Text("Disabled")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Due")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if let nextDue = reminder.nextDueDate {
                        Text(formatDate(nextDue))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isOverdue ? .red : .primary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Single completion button that changes appearance
                    if reminder.isEnabled {
                        Button(action: onComplete) {
                            HStack(spacing: 4) {
                                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16))
                                Text(isCompletedToday ? "Done" : "Mark Done")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(isCompletedToday ? .green : .blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isCompletedToday ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button(action: {
                        showActionSheet = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isOverdue ? Color.red.opacity(0.3) : 
                    isUpcoming ? Color.orange.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $showDailyTracking) {
            if let plant = reminder.plant {
                DailyCompletionView(plant: plant, reminder: reminder)
                    .environmentObject(reminderManager)
            }
        }
        .contextMenu {
            if reminder.isEnabled {
                Button(action: onComplete) {
                    Label(isCompletedToday ? "Mark as Undone" : "Mark as Done", systemImage: isCompletedToday ? "circle" : "checkmark.circle.fill")
                }
            }
            
            Button(action: {
                reminderManager.snoozeReminder(reminder, by: 1 * 60 * 60) // 1 hour
            }) {
                Label("Remind in 1 hour", systemImage: "clock")
            }
            
            Button(action: {
                reminderManager.snoozeReminder(reminder, by: 24 * 60 * 60) // 24 hours
            }) {
                Label("Remind tomorrow", systemImage: "calendar")
            }
            
            Divider()
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
        .confirmationDialog("Reminder Actions", isPresented: $showActionSheet) {
            if reminder.isEnabled {
                Button(isCompletedToday ? "Mark as Undone" : "Mark as Done") {
                    onComplete()
                }
            }
            
            Button("Remind in 1 hour") {
                reminderManager.snoozeReminder(reminder, by: 1 * 60 * 60)
            }
            
            Button("Remind tomorrow") {
                reminderManager.snoozeReminder(reminder, by: 24 * 60 * 60)
            }
            
            Button("Edit") {
                onEdit()
            }
            
            Button("Delete", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an action for this reminder")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDate(date, inSameDayAs: Date().addingTimeInterval(TimeInterval(2 * 24 * 60 * 60))) {
            return "In 2 days"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

#Preview {
    CareRemindersListView(plant: Plant())
        .environmentObject(CareReminderManager.shared)
} 
