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
    var renderer: MTKViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        mtkView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true

        mtkView.device = MTLCreateSystemDefaultDevice()
        device = mtkView.device

        let scene = Scene(device: device)
        scene.sceneProps?.viewMatrix = createTranslationMatrix(x: 0, y: 0, z: -4)

        // Triangle

        let poly1 = RegularPolygon(35, color: simd_float4(1.0, 0.0, 0.0, 1.0))
        poly1.triangleFillMode = .lines
        poly1.rotationMatrix.angleEquation = RMUnaryOp(type: .cos, child: RMTime())
        scene.add(poly1)

        let poly2 = RegularPolygon(50, color: simd_float4(1.0, 0.0, 0.0, 1.0))
        poly2.triangleFillMode = .lines
        poly2.rotationMatrix.angleEquation = RMUnaryOp(type: .sin, child: RMTime())
        scene.add(poly2)

        let plane1 = Plane(color: simd_float4(1.0, 1.0, 1.0, 1.0))
        plane1.triangleFillMode = .lines
        plane1.rotationMatrix.angleEquation = RMTime()
        scene.add(plane1)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
