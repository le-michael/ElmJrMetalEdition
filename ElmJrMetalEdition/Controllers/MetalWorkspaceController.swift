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

        for i in 0 ... 3 {
            let numPlanets = (i * 15) + 10
            for j in 0 ... numPlanets {
                let planet = RegularPolygon(3 + i)
                planet.transform.translationMatrix.setTranslation(
                    x: RMBinaryOp(
                        type: .mul,
                        leftChild: RMConstant(Float(10 + (i * 10))),
                        rightChild: RMUnaryOp(
                            type: .sin,
                            child: RMBinaryOp(
                                type: .add,
                                leftChild: RMBinaryOp(
                                    type: .div,
                                    leftChild: RMTime(),
                                    rightChild: RMConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: RMConstant(Float(j) + 1.0)
                            )
                        )
                    ),
                    y: RMBinaryOp(
                        type: .mul,
                        leftChild: RMConstant(Float(10 + (i * 10))),
                        rightChild: RMUnaryOp(
                            type: .cos,
                            child: RMBinaryOp(
                                type: .add,
                                leftChild: RMBinaryOp(
                                    type: .div,
                                    leftChild: RMTime(),
                                    rightChild: RMConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: RMConstant(Float(j) + 2.0)
                            )
                        )
                    ),
                    z: RMConstant(0)
                )
                planet.transform.scaleMatrix.setScale(x: 1 + Float(i) * 0.25, y: 1 + Float(i) * 0.25, z: 1)
                planet.transform.zRotationMatrix.setZRotation(angle: RMTime())
                planet.color.setColor(
                    r: RMUnaryOp(
                        type: .cos,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(Float(j) + 0.5)
                        )
                    ),
                    g: RMUnaryOp(
                        type: .sin,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(Float(j) + Float(i) * 1.5)
                        )
                    ),
                    b: RMUnaryOp(
                        type: .sin,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(1.5)
                        )
                    ),
                    a: RMConstant(1)
                )
                scene.add(planet)
            }
        }

        for i in 0 ... 3 {
            let numPlanets = (i * 15) + 10
            for j in 0 ... numPlanets {
                let planet = RegularPolygon(3 + i)
                planet.transform.translationMatrix.setTranslation(
                    x: RMBinaryOp(
                        type: .mul,
                        leftChild: RMConstant(Float(10 + (i * 10))),
                        rightChild: RMUnaryOp(
                            type: .sin,
                            child: RMBinaryOp(
                                type: .add,
                                leftChild: RMBinaryOp(
                                    type: .div,
                                    leftChild: RMTime(),
                                    rightChild: RMConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: RMConstant(Float(j) + 1.0)
                            )
                        )
                    ),
                    y: RMBinaryOp(
                        type: .mul,
                        leftChild: RMConstant(Float(10 + (i * 10))),
                        rightChild: RMUnaryOp(
                            type: .sin,
                            child: RMBinaryOp(
                                type: .add,
                                leftChild: RMBinaryOp(
                                    type: .div,
                                    leftChild: RMTime(),
                                    rightChild: RMConstant(Float(i + 1)
                                    )
                                ),
                                rightChild: RMConstant(Float(j) + 2.0)
                            )
                        )
                    ),
                    z: RMConstant(0)
                )
                planet.transform.scaleMatrix.setScale(x: 1 + Float(i) * 0.25, y: 1 + Float(i) * 0.25, z: 1)
                planet.transform.zRotationMatrix.setZRotation(angle: RMTime())
                planet.color.setColor(
                    r: RMUnaryOp(
                        type: .cos,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(Float(j) + 0.5)
                        )
                    ),
                    g: RMUnaryOp(
                        type: .sin,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(Float(j) + Float(i) * 1.5)
                        )
                    ),
                    b: RMUnaryOp(
                        type: .cos,
                        child: RMBinaryOp(
                            type: .add,
                            leftChild: RMTime(),
                            rightChild: RMConstant(2.6)
                        )
                    ),
                    a: RMConstant(1)
                )
                scene.add(planet)
            }
        }

        let sun = RegularPolygon(30)
        sun.transform.scaleMatrix.setScale(x: 2.5, y: 2.5, z: 1)
        sun.color.setColor(
            r: RMUnaryOp(type: .cos, child: RMTime()),
            g: RMUnaryOp(type: .sin, child: RMTime()),
            b: RMConstant(1),
            a: RMConstant(1)
        )
        scene.add(sun)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
