//
//  LottieWrapperView.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import Lottie

struct LottieWrapperView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    typealias UIViewType = UIView

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: name)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            animationView.rightAnchor.constraint(equalTo: view.rightAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        animationView.loopMode = loopMode
        animationView.play()
        return view

    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
