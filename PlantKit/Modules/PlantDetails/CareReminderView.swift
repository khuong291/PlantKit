//
//  CareReminderView.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI
import CoreData

struct CareReminderView: View {
    let plant: Plant
    let reminder: CareReminder?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reminderManager: CareReminderManager
    @State private var selectedType: ReminderType = .watering
    @State private var frequency: Int16 = 7
    @State private var selectedRepeatType: RepeatType = .days
    @State private var reminderTime: Date = Date()
    @State private var notes: String = ""
    @State private var isEnabled: Bool = true
    
    private let frequencyOptions: [(Int16, String)] = Array(1...31).map { ($0, "\($0)") }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appScreenBackgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        reminderTypeSection
                        timeSection
                        frequencySection
                        notesSection
                        enableSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle(reminder == nil ? "Add Reminder" : "Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(reminder == nil ? "Add" : "Save") {
                        saveReminder()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupInitialValues()
            // Request notification permission when user opens reminder view
            reminderManager.requestNotificationPermission()
        }
    }
    
    private var reminderTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder Type")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ReminderType.allCases, id: \.self) { type in
                    ReminderTypeCard(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                        if reminder == nil {
                            frequency = type.defaultFrequency
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder Time")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repeat")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Frequency picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Every")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencyOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                .frame(maxWidth: .infinity)
                
                // Repeat type picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repeat")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Picker("Repeat Type", selection: $selectedRepeatType) {
                        ForEach(RepeatType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField("Add notes about this reminder...", text: $notes, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .lineLimit(3...6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var enableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                Text("Enable Reminder")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func setupInitialValues() {
        if let reminder = reminder {
            if let type = reminderManager.getReminderType(from: reminder.reminderType ?? "") {
                selectedType = type
            }
            frequency = reminder.frequency
            if let repeatTypeString = reminder.repeatType,
               let repeatType = reminderManager.getRepeatType(from: repeatTypeString) {
                selectedRepeatType = repeatType
            }
            reminderTime = reminder.reminderTime ?? Date()
            notes = reminder.notes ?? ""
            isEnabled = reminder.isEnabled
        } else {
            selectedType = .watering
            frequency = selectedType.defaultFrequency
            selectedRepeatType = .days
            reminderTime = Date()
            notes = ""
            isEnabled = true
        }
    }
    
    private func saveReminder() {
        // Request notification permission before creating/updating reminder
        reminderManager.requestNotificationPermission()
        
        if let reminder = reminder {
            reminderManager.updateReminder(reminder, frequency: frequency, repeatType: selectedRepeatType, reminderTime: reminderTime, notes: notes.isEmpty ? nil : notes, isEnabled: isEnabled)
        } else {
            reminderManager.createReminder(for: plant, type: selectedType, frequency: frequency, repeatType: selectedRepeatType, reminderTime: reminderTime, notes: notes.isEmpty ? nil : notes)
        }
        
        Haptics.shared.play()
        dismiss()
    }
}

struct ReminderTypeCard: View {
    let type: ReminderType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(type.color)
                
                Text(type.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
                            .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? type.color.opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CareReminderView(plant: Plant(), reminder: nil)
        .environmentObject(CareReminderManager.shared)
} 