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
                
                if reminderManager.reminders.isEmpty {
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
            // Request notification permission when user opens reminders
            reminderManager.requestNotificationPermission()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Care Reminders")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Set up reminders to help you take care of your \(plant.commonName ?? "plant")")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showAddReminder = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add First Reminder")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var remindersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(reminderManager.reminders, id: \.id) { reminder in
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let type = reminderType {
                    Image(systemName: type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(type.color)
                        .frame(width: 24)
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
                
                HStack(spacing: 12) {
                    Button(action: onComplete) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                            .frame(width: 44, height: 44)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(Color.red.opacity(0.1))
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