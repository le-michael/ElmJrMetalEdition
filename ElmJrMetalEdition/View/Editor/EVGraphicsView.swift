//
//  EVGraphicsView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit
import UIKit

class EVGraphicsView: UIView {
    let mtkView = MTKView()
    var renderer: EGRenderer!

    var previousScale: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mtkView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)

        let scene = EGDemoScenes.cactus()
        renderer = EGRenderer(view: mtkView, scene: scene)
        mtkView.delegate = renderer

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        mtkView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        mtkView.addGestureRecognizer(pinch)
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let delta = simd_float2(Float(translation.x), Float(-translation.y))
        renderer.scene.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let delta = Float(gesture.scale - previousScale)
        renderer.scene.camera.zoom(delta: delta)

        previousScale = gesture.scale
        if gesture.state == .ended {
            previousScale = 1
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
