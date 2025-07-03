import SwiftUI

struct OnboardingIdentifyTimeStepView: View {
    @Binding var selectedTime: IdentifyTimeOption?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Question
                VStack(alignment: .leading, spacing: 8) {
                    Text("How long does it take you to identify a plant?")
                        .font(.system(size: 34)).bold()
                        .padding(.top, 20)
                    Text("We aim to get you results in seconds with just a photo")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                // Options
                VStack(spacing: 16) {
                    ForEach(IdentifyTimeOption.allCases, id: \ .self) { option in
                        IdentifyTimeOptionView(option: option, isSelected: selectedTime == option)
                            .onTapGesture {
                                Haptics.shared.play()
                                withAnimation {
                                    selectedTime = option
                                }
                            }
                    }
                }
                .padding(.bottom, 32)
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 32)
        }
    }
}

// MARK: - Identify Time Option Enum

enum IdentifyTimeOption: String, CaseIterable {
    case seconds, minutes, long, never
    
    var title: String {
        switch self {
        case .seconds: return "A few seconds"
        case .minutes: return "A few minutes"
        case .long: return "A long time"
        case .never: return "I'm never really sure"
        }
    }
    
    var subtitle: String {
        switch self {
        case .seconds: return "I can tell right away"
        case .minutes: return "I need to compare and check"
        case .long: return "I do a lot of research"
        case .never: return "I usually stay uncertain"
        }
    }
    
    var icon: String {
        switch self {
        case .seconds: return "bolt"
        case .minutes: return "clock"
        case .long: return "hourglass"
        case .never: return "questionmark"
        }
    }
}

// MARK: - Option View

struct IdentifyTimeOptionView: View {
    let option: IdentifyTimeOption
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: option.icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .green : .primary)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                Text(option.subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.15) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.green : Color.white, lineWidth: isSelected ? 1.5 : 1.5)
                .padding(1.5)
        )
    }
}

#Preview {
    OnboardingIdentifyTimeStepView(selectedTime: .constant(nil))
} 
