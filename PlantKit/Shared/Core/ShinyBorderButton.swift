//
//  ShinyBorderButton.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct ShinyBorderButton: View {
    let systemName: String
    let title: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: systemName)
                Text(title)
            }
            .font(.system(size: 20))
            .fontWeight(.semibold)
            .foregroundColor(.white)

            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.green)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
            }
            .overlay {
                ShiningLines()
                    .clipShape(Capsule())
            }
        }
    }
}

struct ShiningLines: View {
    let duration: TimeInterval = 2.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let progress = now.truncatingRemainder(dividingBy: duration) / duration
            let shineX = CGFloat(progress) * 400 - 100 // Starts off-screen left and moves to right

            Canvas { context, size in
                let shineWidth: CGFloat = 60
                let topY: CGFloat = 1
                let bottomY: CGFloat = size.height - 1

                let gradient = Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .white.opacity(0.9), location: 0.5),
                    .init(color: .clear, location: 1.0),
                ])

                // Top shine line
                var topLine = Path()
                topLine.move(to: CGPoint(x: shineX, y: topY))
                topLine.addLine(to: CGPoint(x: shineX + shineWidth, y: topY))
                context.stroke(topLine, with: .linearGradient(gradient,
                                                              startPoint: CGPoint(x: shineX, y: topY),
                                                              endPoint: CGPoint(x: shineX + shineWidth, y: topY)),
                               lineWidth: 2)

                // Bottom shine line
                var bottomLine = Path()
                bottomLine.move(to: CGPoint(x: shineX, y: bottomY))
                bottomLine.addLine(to: CGPoint(x: shineX + shineWidth, y: bottomY))
                context.stroke(bottomLine, with: .linearGradient(gradient,
                                                                 startPoint: CGPoint(x: shineX, y: bottomY),
                                                                 endPoint: CGPoint(x: shineX + shineWidth, y: bottomY)),
                               lineWidth: 2)
            }
        }
    }
}

