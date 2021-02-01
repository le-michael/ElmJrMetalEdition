//
//  MetalWorkspaceController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-10-09.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit
import UIKit

class MetalWorkspaceController: UIViewController {
    let mtkView = MTKView()

    var device: MTLDevice!
    var renderer: EGRenderer!

    var previousScale: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        view = mtkView

        mtkView.device = MTLCreateSystemDefaultDevice()
        device = mtkView.device

        let scene = EGDemoScenes.spinningFan()

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(view: mtkView, scene: scene)
        mtkView.delegate = renderer

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        mtkView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        mtkView.addGestureRecognizer(pinch)
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let scene = renderer.scene else { return }

        let translation = gesture.translation(in: gesture.view)
        let delta = simd_float2(Float(translation.x), Float(-translation.y))
        scene.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let scene = renderer.scene else { return }

        let delta = Float(gesture.scale - previousScale)
        scene.camera.zoom(delta: delta)

        previousScale = gesture.scale
        if gesture.state == .ended {
            previousScale = 1
        }
    }
}
