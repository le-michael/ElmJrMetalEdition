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

        for i in 0 ... 4 {
            for j in 0 ... 100 {
                let planet = EGRegularPolygon(3 + i)
                planet.transform.translationMatrix.setTranslation(
                    x: EGBinaryOp(
                        type: .mul,
                        leftChild: EGFloatConstant(Float(10 + (i * 10))),
                        rightChild: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGBinaryOp(
                                    type: .div,
                                    leftChild: EGTime(),
                                    rightChild: EGFloatConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: EGFloatConstant(Float(j) + 1.0)
                            )
                        )
                    ),
                    y: EGBinaryOp(
                        type: .mul,
                        leftChild: EGFloatConstant(Float(10 + (i * 10))),
                        rightChild: EGUnaryOp(
                            type: .cos,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGBinaryOp(
                                    type: .div,
                                    leftChild: EGTime(),
                                    rightChild: EGFloatConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: EGFloatConstant(Float(j) + 2.0)
                            )
                        )
                    ),
                    z: EGFloatConstant(0)
                )
                planet.transform.scaleMatrix.setScale(x: 1 + Float(i) * 0.25, y: 1 + Float(i) * 0.25, z: 1)
                planet.transform.zRotationMatrix.setZRotation(angle: EGTime())
                planet.color.setColor(
                    r: EGUnaryOp(
                        type: .cos,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGTime(),
                            rightChild: EGFloatConstant(Float(j) + 0.5)
                        )
                    ),
                    g: EGUnaryOp(
                        type: .sin,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGTime(),
                            rightChild: EGFloatConstant(Float(j) + Float(i) * 1.5)
                        )
                    ),
                    b: EGFloatConstant(1),
                    a: EGFloatConstant(1)
                )
                scene.add(planet)
            }
        }

        for i in 0 ... 4 {
            for j in 0 ... 100 {
                let planet = EGRegularPolygon(3 + i)
                planet.transform.translationMatrix.setTranslation(
                    x: EGBinaryOp(
                        type: .mul,
                        leftChild: EGFloatConstant(Float(10 + (i * 10))),
                        rightChild: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGBinaryOp(
                                    type: .div,
                                    leftChild: EGTime(),
                                    rightChild: EGFloatConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: EGFloatConstant(Float(j) + 1.0)
                            )
                        )
                    ),
                    y: EGBinaryOp(
                        type: .mul,
                        leftChild: EGFloatConstant(Float(10 + (i * 10))),
                        rightChild: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGBinaryOp(
                                    type: .div,
                                    leftChild: EGTime(),
                                    rightChild: EGFloatConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: EGFloatConstant(Float(j) + 2.0)
                            )
                        )
                    ),
                    z: EGFloatConstant(0)
                )
                planet.transform.scaleMatrix.setScale(x: 1 + Float(i) * 0.25, y: 1 + Float(i) * 0.25, z: 1)
                planet.transform.zRotationMatrix.setZRotation(angle: EGTime())
                planet.color.setColor(
                    r: EGUnaryOp(
                        type: .cos,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGTime(),
                            rightChild: EGFloatConstant(Float(j) + 0.5)
                        )
                    ),
                    g: EGUnaryOp(
                        type: .sin,
                        child: EGBinaryOp(
                            type: .add,
                            leftChild: EGTime(),
                            rightChild: EGFloatConstant(Float(j) + Float(i) * 1.5)
                        )
                    ),
                    b: EGFloatConstant(1),
                    a: EGFloatConstant(1)
                )
                scene.add(planet)
            }
        }

        let sun = EGRegularPolygon(30)
        sun.transform.scaleMatrix.setScale(x: 2.5, y: 2.5, z: 1)
        sun.color.setColor(
            r: EGUnaryOp(type: .cos, child: EGTime()),
            g: EGUnaryOp(type: .sin, child: EGTime()),
            b: EGFloatConstant(1),
            a: EGFloatConstant(1)
        )
        scene.add(sun)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
