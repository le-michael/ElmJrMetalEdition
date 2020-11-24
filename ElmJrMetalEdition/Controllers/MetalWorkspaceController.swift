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

        let poly1 = RegularPolygon(35)
        poly1.triangleFillMode = .lines
        poly1.transform.zRotationMatrix.angleEquation = RMUnaryOp(type: .cos, child: RMTime())
        scene.add(poly1)

        let poly2 = RegularPolygon(50)
        poly2.triangleFillMode = .lines
        poly2.transform.zRotationMatrix.angleEquation = RMUnaryOp(type: .sin, child: RMTime())
        scene.add(poly2)

        let plane1 = Plane()
        plane1.triangleFillMode = .lines
        scene.add(plane1)

        let line1 = Line2D(p0: simd_float3(-0.5, 0.5, 0), p1: simd_float3(0.5, -0.5, 0), size: 0.01)
        scene.add(line1)

        let point1 = RegularPolygon(4)

        point1.transform.translationMatrix.xEquation = RMConstant(2)
        point1.transform.translationMatrix.yEquation = RMConstant(2)
        point1.transform.scaleMatrix.xEquation = RMConstant(0.03)
        point1.transform.scaleMatrix.yEquation = RMConstant(0.03)
        scene.add(point1)

        let point2 = RegularPolygon(4)
        point2.transform.scaleMatrix.xEquation = RMConstant(0.03)
        point2.transform.scaleMatrix.yEquation = RMConstant(0.03)
        point2.transform.translationMatrix.setTranslation(
            x: RMConstant(1.5),
            y: RMUnaryOp(type: .sin, child: RMTime()),
            z: RMConstant(1)
        )
        scene.add(point2)

        let line2 = Line2D(p0: simd_float3(2, 2, 0), p1: simd_float3(1.5, 1.5, 0), size: 0.03)
        scene.add(line2)

        let poly3 = RegularPolygon(50)
        poly3.color.setColor(
            r: RMUnaryOp(type: .cos, child: RMTime()),
            g: RMUnaryOp(type: .sin, child: RMTime()),
            b: RMConstant(1),
            a: RMConstant(1)
        )
        poly3.transform.translationMatrix.setTranslation(x: -1.5, y: -1, z: 0)
        poly3.transform.scaleMatrix.setScale(x: 0.75, y: 0.75, z: 1)
        scene.add(poly3)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
