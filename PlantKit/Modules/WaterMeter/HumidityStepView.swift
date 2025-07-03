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
            Image(systemName: "wind")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.accentColor)
            
            Text("Indicate humidity level around the plant")
                .font(.system(size: 22)).bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Slider(value: $viewModel.humidity, in: 0...100, step: 1)
                        .tint(.accentColor)
                        .disabled(viewModel.humidityDontKnow)
                    
                    Text("\(Int(viewModel.humidity))%")
                        .font(.system(size: 17))
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
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .onChange(of: viewModel.humidity) { newValue in
            if viewModel.humidityDontKnow {
                viewModel.humidityDontKnow = false
            }
        }
    }
} 
