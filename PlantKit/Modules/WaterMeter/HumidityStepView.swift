//
//  HumidityStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct HumidityStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel
    var handleSwipe: (Bool) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            Image(systemName: "wind")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.accentColor)
            
            Text("Indicate humidity level around the plant")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Slider(value: $viewModel.humidity, in: 0...100, step: 1)
                        .tint(.accentColor)
                        .disabled(viewModel.humidityDontKnow)
                    
                    Text("\(Int(viewModel.humidity))%")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 50)
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.humidityDontKnow = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            handleSwipe(true)
                        }
                    }
                }) {
                    Text("I don't know")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
            Spacer()
            Spacer()
        }
        .padding()
        .onChange(of: viewModel.humidity) {
            if viewModel.humidityDontKnow {
                viewModel.humidityDontKnow = false
            }
        }
    }
} 