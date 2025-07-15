//
//  DailyCompletionView.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI

struct DailyCompletionView: View {
    let plant: Plant
    let reminder: CareReminder
    @EnvironmentObject private var reminderManager: CareReminderManager
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false
    
    private let calendar = Calendar.current
    private let daysToShow = 7
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Tracking")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack(spacing: 4) {
                        Text(formatDate(selectedDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Completion streak
            let streak = reminderManager.getCompletionStreak(for: reminder)
            if streak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(streak) day streak!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Daily completion grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<daysToShow, id: \.self) { index in
                    let date = calendar.date(byAdding: .day, value: -index, to: selectedDate) ?? selectedDate
                    let isCompleted = reminderManager.isCompletionMarked(for: reminder, date: date)
                    let isToday = calendar.isDateInToday(date)
                    
                    DailyCompletionCell(
                        date: date,
                        isCompleted: isCompleted,
                        isToday: isToday,
                        onTap: {
                            if isCompleted {
                                reminderManager.unmarkDailyCompletion(for: reminder, date: date)
                            } else {
                                reminderManager.markDailyCompletion(for: reminder, date: date)
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDate: $selectedDate)
        }
        .onAppear {
            reminderManager.loadDailyCompletions(for: plant)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DailyCompletionCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCompleted ? .white : .primary)
                
                Text(calendar.veryShortWeekdaySymbols[calendar.component(.weekday, from: date) - 1])
                    .font(.system(size: 10))
                    .foregroundColor(isCompleted ? .white.opacity(0.8) : .secondary)
            }
            .frame(width: 40, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isToday {
            return Color.blue.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DailyCompletionView(plant: Plant(), reminder: CareReminder())
        .environmentObject(CareReminderManager.shared)
} 