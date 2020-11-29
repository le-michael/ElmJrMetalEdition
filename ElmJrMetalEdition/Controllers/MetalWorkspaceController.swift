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

        let sun = EGRegularPolygon(30)
        sun.transform.scaleMatrix.setScale(x: 2.5, y: 2.5, z: 1)
        sun.color.setColor(
            r: EGUnaryOp(type: .cos, child: EGTime()),
            g: EGUnaryOp(type: .sin, child: EGTime()),
            b: EGConstant(1),
            a: EGConstant(1)
        )
        scene.add(sun)
        
        let planet = EGRegularPolygon(30)
        planet.transform.translationMatrix.setTranslation(
            x: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(8),
                rightChild: EGUnaryOp(type: .cos, child: EGTime())
            ),
            y: EGConstant(0),
            z: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(8),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        scene.add(planet)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
