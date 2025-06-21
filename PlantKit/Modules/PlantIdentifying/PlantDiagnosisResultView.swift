import SwiftUI

struct PlantDiagnosisResultView: View {
    let image: UIImage
    let diagnosis: HealthCheck.Diagnosis
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with image
                    headerSection
                    
                    // Health Score Card
                    healthScoreCard
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Overall Condition
                    conditionCard
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Disease Risk
                    diseaseRiskCard
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Health Issues
                    if !diagnosis.healthIssues.isEmpty {
                        healthIssuesCard
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    
                    // Recommendations
                    recommendationsCard
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                
                VStack(spacing: 8) {
                    Text("Plant Health Diagnosis")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Analysis Complete")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 20)
            }
            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .padding(.trailing)
                    .padding(.top, 46)
            }
        }
    }
    
    private var healthScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Health Score")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(diagnosis.healthScore) / 100)
                        .stroke(healthScoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(diagnosis.healthScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(healthScoreColor)
                        Text("%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(healthScoreDescription)
                        .font(.headline)
                        .foregroundColor(healthScoreColor)
                    
                    Text(healthScoreDetail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var conditionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Overall Condition")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(diagnosis.overallCondition)
                .font(.body)
                .foregroundColor(.primary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var diseaseRiskCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(diseaseRiskColor)
                Text("Disease Risk")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(diagnosis.diseaseRisk)
                .font(.body)
                .foregroundColor(.primary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(diseaseRiskColor.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var healthIssuesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundColor(.orange)
                Text("Health Issues")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(diagnosis.healthIssues, id: \.self) { issue in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.orange)
                            .padding(.top, 8)
                        
                        Text(issue)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.blue)
                Text("Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(diagnosis.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .padding(.top, 2)
                        
                        Text(recommendation)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var healthScoreColor: Color {
        switch diagnosis.healthScore {
        case 80...100:
            return .green
        case 60..<80:
            return .orange
        default:
            return .red
        }
    }
    
    private var healthScoreDescription: String {
        switch diagnosis.healthScore {
        case 80...100:
            return "Excellent Health"
        case 60..<80:
            return "Good Health"
        case 40..<60:
            return "Fair Health"
        default:
            return "Poor Health"
        }
    }
    
    private var healthScoreDetail: String {
        switch diagnosis.healthScore {
        case 80...100:
            return "Your plant is in excellent condition with minimal health concerns."
        case 60..<80:
            return "Your plant is generally healthy but may need some attention."
        case 40..<60:
            return "Your plant shows signs of stress and needs care."
        default:
            return "Your plant requires immediate attention and care."
        }
    }
    
    private var diseaseRiskColor: Color {
        let risk = diagnosis.diseaseRisk.lowercased()
        if risk.contains("low") {
            return .green
        } else if risk.contains("medium") {
            return .orange
        } else {
            return .red
        }
    }
} 
