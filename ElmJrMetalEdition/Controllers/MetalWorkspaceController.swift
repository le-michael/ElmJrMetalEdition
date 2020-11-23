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
        poly1.transforms.zRotationMatrix.angleEquation = RMUnaryOp(type: .cos, child: RMTime())
        scene.add(poly1)

        let poly2 = RegularPolygon(50, color: simd_float4(1.0, 0.0, 0.0, 1.0))
        poly2.triangleFillMode = .lines
        poly2.transforms.zRotationMatrix.angleEquation = RMUnaryOp(type: .sin, child: RMTime())
        scene.add(poly2)

        let plane1 = Plane(color: simd_float4(1.0, 1.0, 1.0, 1.0))
        plane1.triangleFillMode = .lines
        scene.add(plane1)

        let line1 = Line2D(p0: simd_float3(-0.5, 0.5, 0), p1: simd_float3(0.5, -0.5, 0), size: 0.01, color: simd_float4(1.0, 1.0, 0.0, 1.0))
        scene.add(line1)

        let point1 = RegularPolygon(4, color: simd_float4(1.0, 1.0, 1.0, 1.0))

        point1.transforms.translationMatrix.xEquation = RMConstant(2)
        point1.transforms.translationMatrix.yEquation = RMConstant(2)
        point1.transforms.scaleMatrix.xEquation = RMConstant(0.03)
        point1.transforms.scaleMatrix.yEquation = RMConstant(0.03)
        scene.add(point1)

        let point2 = RegularPolygon(4, color: simd_float4(1.0, 1.0, 1.0, 1.0))
        point2.transforms.translationMatrix.xEquation = RMConstant(1.5)
        point2.transforms.translationMatrix.yEquation = RMConstant(1.5)
        point2.transforms.scaleMatrix.xEquation = RMConstant(0.03)
        point2.transforms.scaleMatrix.yEquation = RMConstant(0.03)
        scene.add(point2)

        let line2 = Line2D(p0: simd_float3(2, 2, 0), p1: simd_float3(1.5, 1.5, 0), size: 0.03, color: simd_float4(0.0, 0.0, 1.0, 1.0))
        scene.add(line2)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
