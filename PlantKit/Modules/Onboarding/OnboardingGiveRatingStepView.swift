//
//  OnboardingGiveRatingStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI

struct OnboardingGiveRatingStepView: View {
    @Environment(\.requestReview) var requestReview
    @Binding var requested: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Text("Rate PlantKit")
                        .font(.largeTitle).bold()
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                HStack {
                    ForEach(0 ..< 5) { _ in
                        Text("⭐")
                            .font(.largeTitle)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
                    .frame(height: 60)
                HStack {
                    Spacer()
                    VStack(spacing: 30) {
                        Text("PlantKit was made for plant lovers like you")
                            .font(.title.bold())
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        VStack {
                            HStack {
                                Image("OnboardingBigFaceImage1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 4)
                                    )
                                
                                Image("OnboardingBigFaceImage2")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 4)
                                    )
                                    .offset(x: -20)

                                Image("OnboardingBigFaceImage3")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 4)
                                    )
                                    .offset(x: -40)
                            }
                            .offset(x: 30)
                            Text("+50k PlantKit users").font(.footnote).fontWeight(.medium)
                        }
                    }
                    Spacer()
                }
                Spacer()
                    .frame(height: 60)
                TrustedViewCard(name: "Samantha Rae", review: "PlantKit helped me finally identify all the plants in my garden. The AI is incredibly accurate and the care tips are spot on! 🌱", profileImage: "OnboardingFaceImage1")
                Spacer().frame(height: 10)
                TrustedViewCard(name: "Liam Carter", review: "This app is a game-changer for plant care. I can identify any plant instantly and get personalized care advice. My plants have never been happier!", profileImage: "OnboardingFaceImage2")
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            guard !requested else {
                return
            }

            requestReview()

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                requested = true
            }
        }
    }
}

extension OnboardingGiveRatingStepView {
    struct TrustedViewCard: View {
        let name: String
        let review: String
        let profileImage: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    Text(name).font(.body.bold())
                    Text("⭐⭐⭐⭐⭐").font(.body)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                }
                
                HStack {
                    Text(review).font(.body)
                        .opacity(0.8)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.secondary.opacity(0.2))
            .cornerRadius(20)
        }
    }
}

#Preview {
    OnboardingGiveRatingStepView(requested: .constant(false))
}
