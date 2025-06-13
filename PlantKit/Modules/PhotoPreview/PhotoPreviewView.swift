//
//  PhotoPreviewView.swift
//  PlantKit
//
//  Created by Khuong Pham on 5/6/25.
//

import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    let onIdentify: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        onDismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera")
                            Text("Retake")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 50)
                .padding(.trailing, 10)

                Spacer()

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 2)
                    )

                Spacer()

                ShinyBorderButton {
                    onIdentify()
                }
                .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
