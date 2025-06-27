import SwiftUI

struct OnboardingPlantDetailsStepView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Identify your Plant")
                        .font(.largeTitle).bold()
                        .padding(.top, 20)
                    Text("Get all the details you need in seconds")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // Phone mockup with plant details card
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 8)
                        .frame(width: 260, height: 520)
                    VStack(spacing: 0) {
                        // Plant Details Header
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Image("photo-taken-img")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 260, height: 160)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                HStack {
                                    Text("★ Common in Suitable Climates.")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.8))
                                        .clipShape(Capsule())
                                        .padding(8)
                                    Spacer()
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Red Spider Lily")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Lycoris radiata")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                Text("Higanbana, Manjusaka")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "text.justify.left")
                                    .foregroundColor(.gray)
                                Text("Description")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.primary)
                            }
                            Text("Red Spider Lily is a captivating flower known for its striking appearance and vibrant red color. 🌺\n\nThe flowers bloom in late summer to early autumn, often appearing suddenly after a period of rain. Each bulb produces long, slender stems that can reach up to 2 feet tall.")
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        
                        // Chat Button (visual only)
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Text("3")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.green)
                            }
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .foregroundColor(.white)
                                    Text("Chat")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                            .disabled(true)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .padding(.bottom, 8)
                    }
                    .frame(width: 250)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(radius: 2)
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

#Preview {
    OnboardingPlantDetailsStepView()
} 