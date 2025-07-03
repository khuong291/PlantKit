//
//  TemperatureStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct TemperatureStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel
    var handleSwipe: (Bool) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Image(systemName: "thermometer")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.accentColor)
            
            Text("Indicate temperature around the plant")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Slider(
                        value: $viewModel.temperature,
                        in: viewModel.temperatureUnit == .celsius ? 0...40 : 32...104,
                        step: 1
                    )
                    .tint(.accentColor)
                    .disabled(viewModel.temperatureDontKnow)
                    
                    Text("\(Int(viewModel.temperature))°\(viewModel.temperatureUnit.rawValue)")
                        .font(.system(size: 17).weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 60)
                }
                
                Picker("Unit", selection: $viewModel.temperatureUnit) {
                    Text("°C").tag(TemperatureUnit.celsius)
                    Text("°F").tag(TemperatureUnit.fahrenheit)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(viewModel.temperatureDontKnow)
                
                Button(action: {
                    withAnimation {
                        viewModel.temperatureDontKnow = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            handleSwipe(true)
                        }
                    }
                }) {
                    Text("I don't know")
                        .font(.system(size: 17).weight(.semibold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .onChange(of: viewModel.temperature) { newValue in
            if viewModel.temperatureDontKnow {
                viewModel.temperatureDontKnow = false
            }
        }
    }
} 
