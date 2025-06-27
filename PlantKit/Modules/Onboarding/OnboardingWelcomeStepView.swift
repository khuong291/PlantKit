//
//  OnboardingWelcomeStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI

struct OnboardingWelcomeStepView: View {
    @EnvironmentObject private var viewModel: OnboardingScreenModel
    
    @State private var haveAnAccount = true
    
    var body: some View {
        content
            .padding(.top, 80)
            .overlay(alignment: .bottom) {
                VStack {
                    if haveAnAccount {
                        VStack(spacing: 14) {
                            Text("Join thousands of plant lovers! Identify plants, get care tips, and grow your green thumb.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 280)
                                .padding(.bottom, 10)
                            signInWithAppleButton
                            signInWithGoogleButton
                        }
                        .padding(.bottom, 50)
                    } else {
                        Button {
                            withAnimation {
                                haveAnAccount = true
                            }
                        } label: {
                            Text("Have an account?")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
    }
    
    private var content: some View {
        ScrollView {
            VStack {
                Text("Welcome to PlantKit")
                    .font(.system(size: 50).bold())
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                
                Text("Identify Plants. Get Care Tips. Grow Together.")
                    .font(.title)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.top, 4)
                
                getStartedButton
                    .padding(.top, 20)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    private var signInWithAppleButton: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemSymbol: .appleLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("Sign in with Apple")
            }
            .bold()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black.opacity(0.5))
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var signInWithGoogleButton: some View {
        Button {
            
        } label: {
            HStack {
                Image("ic-google")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("Sign in with Google")
            }
            .bold()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black.opacity(0.5))
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var getStartedButton: some View {
        Button {
            Haptics.shared.play()
            withAnimation {
                viewModel.goToNextStep()
            }
        } label: {
            Text("Get started")
                .font(.system(size: 20))
                .bold()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .clipShape(.capsule)
                .padding(.horizontal)
        }
        .buttonStyle(CardButtonStyle())
    }
}

#Preview {
    OnboardingWelcomeStepView()
}

