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
        scene.sceneProps?.viewMatrix = createTranslationMatrix(x: 0, y: 0, z: -100)

        let line1 = Line2D(p0: simd_float3(-200, 0 , 0), p1: simd_float3(200, 0, 0), size: 0.5)
        line1.transform.zRotationMatrix.setZRotation(angle: RMTime())
        scene.add(line1)
        
        let line2 = Line2D(p0: simd_float3(0, -200 , 0), p1: simd_float3(0, 200, 0), size: 0.5)
        line2.transform.zRotationMatrix.setZRotation(angle: RMTime())
        scene.add(line2)
        
        let planet1 = RegularPolygon(5)
        planet1.transform.scaleMatrix.setScale(x: 3, y: 3, z: 1)
        planet1.transform.translationMatrix.setTranslation(
            x: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(30),
                rightChild: RMUnaryOp(type: .sin, child: RMTime())
            ),
            y: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(30),
                rightChild: RMUnaryOp(type: .cos, child: RMTime())
            ),
            z: RMConstant(0)
        )
        planet1.transform.zRotationMatrix.setZRotation(angle: RMTime())
        planet1.color.setColor(
            r: RMConstant(1),
            g: RMUnaryOp(type: .sin, child: RMTime()),
            b: RMUnaryOp(type: .cos, child: RMTime()),
            a: RMConstant(1)
        )
        scene.add(planet1)

        let planet2 = RegularPolygon(4)
        planet2.transform.scaleMatrix.setScale(x: 3, y: 3, z: 1)
        planet2.transform.translationMatrix.setTranslation(
            x: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(20),
                rightChild: RMUnaryOp(
                    type: .sin,
                    child: RMBinaryOp(
                        type: .div,
                        leftChild: RMTime(),
                        rightChild: RMConstant(2)
                    )
                )
            ),
            y: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(20),
                rightChild: RMUnaryOp(
                    type: .cos,
                    child: RMBinaryOp(
                        type: .div,
                        leftChild: RMTime(),
                        rightChild: RMConstant(2)
                    )
                )
            ),
            z: RMConstant(0)
        )
        planet2.color.setColor(
            r: RMUnaryOp(type: .cos, child: RMTime()),
            g: RMUnaryOp(type: .sin, child: RMTime()),
            b: RMConstant(1),
            a: RMConstant(1)
        )
        planet2.transform.zRotationMatrix.setZRotation(angle: RMTime())
        scene.add(planet2)

        let planet3 = RegularPolygon(3)
        planet3.transform.scaleMatrix.setScale(x: 3, y: 3, z: 1)
        planet3.transform.translationMatrix.setTranslation(
            x: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(10),
                rightChild: RMUnaryOp(type: .sin, child: RMTime())
            ),
            y: RMBinaryOp(
                type: .mul,
                leftChild: RMConstant(10),
                rightChild: RMUnaryOp(type: .cos, child: RMTime())
            ),
            z: RMConstant(0)
        )
        planet3.color.setColor(
            r: RMUnaryOp(type: .sin, child: RMTime()),
            g: RMConstant(1),
            b: RMUnaryOp(type: .cos, child: RMTime()),
            a: RMConstant(1)
        )
        planet3.transform.zRotationMatrix.setZRotation(angle: RMTime())
        scene.add(planet3)

        let sun = RegularPolygon(30)
        sun.transform.scaleMatrix.setScale(x: 5, y: 5, z: 1)
        sun.color.setColor(r: 1, g: 1, b: 0, a: 0)
        scene.add(sun)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
