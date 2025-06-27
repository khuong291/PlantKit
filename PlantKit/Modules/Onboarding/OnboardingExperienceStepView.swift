import SwiftUI

struct OnboardingExperienceStepView: View {
    @Binding var selectedLevel: ExperienceLevel?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Question
                VStack(alignment: .leading, spacing: 8) {
                    Text("How experienced are you with plants?")
                        .font(.largeTitle).bold()
                        .padding(.top, 20)
                    Text("From curious beginner to seasoned grower, we'd love to know where you stand.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                // Options
                VStack(spacing: 16) {
                    ForEach(ExperienceLevel.allCases, id: \ .self) { level in
                        ExperienceOptionView(level: level, isSelected: selectedLevel == level)
                            .onTapGesture {
                                Haptics.shared.play()
                                withAnimation {
                                    selectedLevel = level
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

// MARK: - Experience Level Enum

enum ExperienceLevel: String, CaseIterable {
    case beginner, intermediate, advanced, expert
    
    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
    
    var subtitle: String {
        switch self {
        case .beginner: return "Just getting started"
        case .intermediate: return "Some experience, still learning"
        case .advanced: return "Confident and capable"
        case .expert: return "Highly experienced and skilled"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "sparkles"
        case .intermediate: return "chart.bar"
        case .advanced: return "bolt"
        case .expert: return "trophy"
        }
    }
}

// MARK: - Option View

struct ExperienceOptionView: View {
    let level: ExperienceLevel
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: level.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .green : .primary)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(level.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(level.subtitle)
                    .font(.subheadline)
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
    OnboardingExperienceStepView(selectedLevel: .constant(nil))
} 
