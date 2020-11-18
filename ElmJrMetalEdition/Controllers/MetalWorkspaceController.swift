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

        let triangle1 = Triangle(color: simd_float4(0.0, 0.0, 1.0, 1.0))
        scene.addChild(node: triangle1)
        
        let triangle2 = Triangle(color: simd_float4(1.0, 0.0, 1.0, 1.0))
        triangle2.rotationMatrix = createZRotaionMatrix(degrees: 180)
        scene.addChild(node: triangle2)
        
        let triangle3 = Triangle(color: simd_float4(0.0, 1.0, 1.0, 1.0))
        triangle3.translationMatrix = createTranslationMatrix(x: -0.5, y: Float(sqrt(3)/2), z: 0)
        scene.addChild(node: triangle3)
        
        let triangle4 = Triangle(color: simd_float4(0.0, 1.0, 0.0, 1.0))
        triangle4.translationMatrix = createTranslationMatrix(x: 0.5, y: -Float(sqrt(3)/2), z: 0)
        triangle4.rotationMatrix = createZRotaionMatrix(degrees: 180)
        scene.addChild(node: triangle4)
        
        let triangle5 = Triangle(color: simd_float4(1.0, 0.0, 0.0, 1.0))
        triangle5.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        triangle5.rotationMatrix = createZRotaionMatrix(degrees: 45)
        triangle5.translationMatrix = createTranslationMatrix(x: 0.25, y: -0.5, z: 0)
        scene.addChild(node: triangle5)

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
