//
//  PotDiameterStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct PotDiameterStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel
    var handleSwipe: (Bool) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            Image(systemName: "arrow.left.and.right.circle")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.accentColor)
            
            Text("Indicate the pot's diameter")
                .font(.title2).bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Slider(
                        value: $viewModel.potDiameter,
                        in: viewModel.potDiameterUnit == .cm ? 5...100 : 2...40,
                        step: 1
                    )
                    .tint(.accentColor)
                    .disabled(viewModel.potDiameterDontKnow)
                    
                    Text("\(Int(viewModel.potDiameter)) \(viewModel.potDiameterUnit.rawValue)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                }

                Picker("Unit", selection: $viewModel.potDiameterUnit) {
                    Text("cm").tag(PotDiameterUnit.cm)
                    Text("inch").tag(PotDiameterUnit.inch)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(viewModel.potDiameterDontKnow)
                
                Button(action: {
                    withAnimation {
                        viewModel.potDiameterDontKnow = true
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
        .onChange(of: viewModel.potDiameter) {
            if viewModel.potDiameterDontKnow {
                viewModel.potDiameterDontKnow = false
            }
        }
    }
} 