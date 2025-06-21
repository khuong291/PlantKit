//
//  TemperatureStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct TemperatureStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Indicate temperature around the plant")
                .font(.title2).bold()
                .padding(.horizontal)

            VStack(spacing: 16) {
                if !viewModel.temperatureDontKnow {
                    VStack {
                        Text("\(Int(viewModel.temperature))°\(viewModel.temperatureUnit.rawValue)")
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                        
                        Slider(
                            value: $viewModel.temperature,
                            in: viewModel.temperatureUnit == .celsius ? 0...40 : 32...104,
                            step: 1
                        )
                        .padding(.horizontal)
                        
                        Picker("Unit", selection: $viewModel.temperatureUnit) {
                            Text("°C").tag(TemperatureUnit.celsius)
                            Text("°F").tag(TemperatureUnit.fahrenheit)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                }

                Button(action: {
                    withAnimation {
                        viewModel.temperatureDontKnow.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.temperatureDontKnow ? "checkmark.square.fill" : "square")
                        Text("I don't know")
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
} 