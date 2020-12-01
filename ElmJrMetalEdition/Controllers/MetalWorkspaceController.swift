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

        let scene = EGScene(device: device)
        scene.sceneProps?.viewMatrix = EGMatrixBuilder.createTranslationMatrix(x: 0, y: 0, z: -100)

        
        
        let curved = EGCurvedPolygon(
            p0: EGPoint2D(pos: simd_float2(0, 0)),
            p1: EGPoint2D(pos: simd_float2(100, 50)),
            p2: EGPoint2D(pos: simd_float2(50, -100)),
            p3: EGPoint2D(pos: simd_float2(0, 0))
        )
        
        let p2y = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(-100),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(50),
                rightChild: EGUnaryOp(type: .cos, child: EGTime())
            )
        )
        let p2x = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(50),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(20),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        curved.p2.yEquation = p2y
        curved.p2.xEquation = p2x
        
        let p1y = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(50),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(30),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        let p1x = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(100),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(50),
                rightChild: EGUnaryOp(type: .cos, child: EGTime())
            )
        )
        curved.p1.yEquation = p1y
        curved.p1.xEquation = p1x
        
        let p03y = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(0),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(10),
                rightChild: EGUnaryOp(
                    type: .sin,
                    child: EGBinaryOp(
                        type: .add,
                        leftChild: EGRandom(),
                        rightChild: EGTime()
                    )
                )
            )
        )
        let p03x = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(0),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(30),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        curved.p0.yEquation = p03y
        curved.p0.xEquation = p03x
        curved.p3.yEquation = p03y
        curved.p3.xEquation = p03x
        
        
        curved.triangleFillMode = .fill
        curved.color.setColor(
            r: EGBinaryOp(
                type: .max,
                leftChild: EGConstant(0.5),
                rightChild: EGUnaryOp(
                    type: .abs,
                    child: EGUnaryOp(
                        type: .cos,
                        child: EGTime()
                    )
                )
            ),
            g: EGBinaryOp(
                type: .max,
                leftChild: EGConstant(0.3),
                rightChild: EGUnaryOp(
                    type: .abs,
                    child: EGUnaryOp(
                        type: .sin,
                        child: EGTime()
                    )
                )
            ),
            b: EGConstant(1.0),
            a: EGConstant(1.0)
        )
        scene.add(curved)


        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
