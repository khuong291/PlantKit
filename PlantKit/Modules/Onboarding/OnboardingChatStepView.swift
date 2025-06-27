import SwiftUI

struct OnboardingChatStepView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Answer all your questions")
                        .font(.largeTitle).bold()
                        .padding(.top, 20)
                    Text("Chat with your trained AI expert")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // Phone mockup with chat interface
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 8)
                        .frame(width: 260, height: 520)
                    VStack(spacing: 0) {
                        // Chat header
                        HStack {
                            Text("Plant Details")
                                .font(.subheadline).bold()
                                .foregroundColor(.green)
                            Spacer()
                            Text("Chat")
                                .font(.subheadline).bold()
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        
                        // Chat bubbles
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .bottom) {
                                Image(systemName: "phone.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Does it look healthy?")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.green)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    Text("May 23 · 13:39 PM")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "phone.circle.fill")
                                    .foregroundColor(.green)
                                    .opacity(0)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Yes, your Red Spider Lily (Lycoris radiata) looks very healthy! 🌿✨\n\nHere's why:\n- The vibrant red color of the petals is a great sign — healthy flowers tend to have bright, vivid hues.\n- The petals and stamens look firm and intact, with no signs of wilting or browning.\n- The green stems appear strong and upright, which means the plant is well-supported and hydrated.\n\nJust make sure it's getting the right amount of light (full sun to partial shade) and well-draining soil. Avoid overwatering, and it should keep thriving beautifully! 🌞🌱\n\nIf you want, I can also help with tips on care or what to watch out for.")
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                        .padding(10)
                                        .background(Color(.systemGray5))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    Text("May 23 · 13:39 PM")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Input bar (visual only)
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Does it look healthy?")
                                    .font(.footnote)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(Capsule())
                                Text("How much water does it need?")
                                    .font(.footnote)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(Capsule())
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            HStack {
                                TextField("Type a message...", text: .constant(""))
                                    .font(.footnote)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.green)
                                    .padding(.leading, 4)
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.bottom, 10)
                    }
                    .frame(width: 250, height: 500)
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
    OnboardingChatStepView()
} 