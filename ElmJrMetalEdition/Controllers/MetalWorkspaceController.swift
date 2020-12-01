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

        for _ in 0 ... 1000 {
            let poly = EGRegularPolygon(10)
            poly.transform.translationMatrix.setTranslation(
                x: EGBinaryOp(
                    type: .mul,
                    leftChild: EGRandom(range: 1..<50),
                    rightChild: EGUnaryOp(
                        type: .sin,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGRandom(),
                            rightChild: EGTime()
                        )
                    )
                ),
                y: EGBinaryOp(
                    type: .mul,
                    leftChild: EGRandom(range: 1..<50),
                    rightChild: EGUnaryOp(
                        type: .cos,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGRandom(),
                            rightChild: EGTime()
                        )
                    )
                ),
                z: EGBinaryOp(
                    type: .mul,
                    leftChild: EGRandom(range: 0..<50),
                    rightChild: EGUnaryOp(
                        type: .cos,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGRandom(),
                            rightChild: EGTime()
                        )
                    )
                )
            )
            poly.color.setColor(
                r: EGUnaryOp(
                    type: .cos,
                    child: EGBinaryOp(
                        type: .add,
                        leftChild: EGRandom(),
                        rightChild: EGTime()
                    )
                ),
                g: EGUnaryOp(
                    type: .sin,
                    child: EGBinaryOp(
                        type: .add,
                        leftChild: EGRandom(),
                        rightChild: EGTime()
                    )
                ),
                b: EGUnaryOp(
                    type: .cos,
                    child: EGBinaryOp(
                        type: .add,
                        leftChild: EGRandom(),
                        rightChild: EGTime()
                    )
                ),
                a: EGConstant(1)
            )
            scene.add(poly)
        }

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
