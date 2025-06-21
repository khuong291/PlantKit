//
//  HumidityStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct HumidityStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Indicate humidify level around the plant")
                .font(.title2).bold()
                .padding(.horizontal)

            VStack(spacing: 16) {
                if !viewModel.humidityDontKnow {
                    VStack {
                        Text("\(Int(viewModel.humidity))%")
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                        
                        Slider(value: $viewModel.humidity, in: 0...100, step: 1)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    withAnimation {
                        viewModel.humidityDontKnow.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.humidityDontKnow ? "checkmark.square.fill" : "square")
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