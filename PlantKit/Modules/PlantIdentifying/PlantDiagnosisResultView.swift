import SwiftUI

struct PlantDiagnosisResultView: View {
    let image: UIImage
    let diagnosis: HealthCheck.Diagnosis
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.appScreenBackgroundColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Header image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(height: 260)
                        .clipped()
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 0) {
                        Spacer().frame(height: 220)
                        VStack(alignment: .leading, spacing: 20) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 5)
                                .frame(maxWidth: .infinity)
                                .offset(y: -10)

                            // Title
                            VStack(spacing: 8) {
                                Text("Plant Health Diagnosis")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Analysis Complete")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Health Score Card
                            healthScoreCard
                            
                            // Overall Condition
                            conditionCard
                            
                            // Disease Risk
                            diseaseRiskCard
                            
                            // Health Issues
                            if !diagnosis.healthIssues.isEmpty {
                                healthIssuesCard
                            }
                            
                            // Recommendations
                            recommendationsCard
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                        )
                    }
                }
            }
            
            // Custom back button
            Button(action: { onDismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 36, height: 36)
                }
            }
            .padding(.leading, 16)
            .padding(.top, 44) // For safe area
        }
        .background(EnableSwipeBack())
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
    
    private var healthScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Health Score")
                    .font(.system(size: 17))
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
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(healthScoreColor)
                        Text("%")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(healthScoreDescription)
                        .font(.system(size: 17))
                        .foregroundColor(healthScoreColor)
                    
                    Text(healthScoreDetail)
                        .font(.system(size: 15))
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
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(diagnosis.overallCondition)
                .font(.system(size: 15))
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
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(diagnosis.diseaseRisk)
                .font(.system(size: 15))
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
                    .font(.system(size: 17))
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
                            .font(.system(size: 15))
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
                    .font(.system(size: 17))
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
                            .font(.system(size: 15))
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
