//
//  ResultStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

struct ResultStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            
            Text("Your plant needs")
                .font(.title2).bold()

            VStack {
                Text(viewModel.calculatedWaterAmount())
                    .font(.system(size: 64, weight: .bold))
                    .monospacedDigit()
                
                Picker("Unit", selection: $viewModel.resultUnit) {
                    Text("ml").tag(ResultUnit.ml)
                    Text("oz").tag(ResultUnit.oz)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
            
            Text("P.S. Plant requirements depend on pt, soil, light, season, and location")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .padding()
    }
} 