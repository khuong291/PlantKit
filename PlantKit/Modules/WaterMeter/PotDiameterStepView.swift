//
//  PotDiameterStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct PotDiameterStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Indicate the pot's diameter")
                .font(.title2).bold()
                .padding(.horizontal)

            VStack(spacing: 16) {
                if !viewModel.potDiameterDontKnow {
                    VStack {
                        Text("\(Int(viewModel.potDiameter)) \(viewModel.potDiameterUnit.rawValue)")
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                        
                        Slider(
                            value: $viewModel.potDiameter,
                            in: viewModel.potDiameterUnit == .cm ? 5...100 : 2...40,
                            step: 1
                        )
                        .padding(.horizontal)
                        
                        Picker("Unit", selection: $viewModel.potDiameterUnit) {
                            Text("cm").tag(PotDiameterUnit.cm)
                            Text("inch").tag(PotDiameterUnit.inch)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                }

                Button(action: {
                    withAnimation {
                        viewModel.potDiameterDontKnow.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.potDiameterDontKnow ? "checkmark.square.fill" : "square")
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