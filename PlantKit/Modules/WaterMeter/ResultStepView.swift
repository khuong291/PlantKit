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
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.calculatedWaterAmount())
                    .font(.system(size: 72, weight: .bold))
                Text(viewModel.resultUnit.rawValue)
                    .font(.system(size: 36, weight: .bold))
            }
            .foregroundColor(.accentColor)
            .monospacedDigit()
            
            Text("Your plant needs")
                .font(.title2).bold()
                .offset(y: -10)
            
            Text("P.S. Plant requirements depend on pt, soil, light, season, and location")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Picker("Unit", selection: $viewModel.resultUnit) {
                Text("ML").tag(ResultUnit.ml)
                Text("OZ").tag(ResultUnit.oz)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)
            .padding(.top)
        }
        .padding()
    }
} 