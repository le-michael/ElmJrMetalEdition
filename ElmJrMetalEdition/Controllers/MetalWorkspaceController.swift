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
        
        let triangleNormal = NRegularPolygon(numOfSides: 3, color: simd_float4(1.0, 0.0, 0.0, 1.0))
        triangleNormal.translationMatrix = createTranslationMatrix(x: -0.75, y: 1.5, z: 0)
        triangleNormal.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: triangleNormal)
        
        let triangleWire = NRegularPolygon(numOfSides: 3, color: simd_float4(1.0, 0.0, 0.0, 1.0))
        triangleWire.triangleFillMode = .lines
        triangleWire.translationMatrix = createTranslationMatrix(x: 0.75, y: 1.5, z: 0)
        triangleWire.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: triangleWire)
        
        // Hexagon
        
        let hexagonNormal = NRegularPolygon(numOfSides: 6, color: simd_float4(1.0, 0.0, 1.0, 1.0))
        hexagonNormal.translationMatrix = createTranslationMatrix(x: -0.75, y: 0.5, z: 0)
        hexagonNormal.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: hexagonNormal)
        
        let hexagonWire = NRegularPolygon(numOfSides: 6, color: simd_float4(1.0, 0.0, 1.0, 1.0))
        hexagonWire.triangleFillMode = .lines
        hexagonWire.translationMatrix = createTranslationMatrix(x: 0.75, y: 0.5, z: 0)
        hexagonWire.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: hexagonWire)
        
        // Circle
        
        let circleNormal = NRegularPolygon(numOfSides: 30, color: simd_float4(0.0, 1.0, 0.0, 1.0))
        circleNormal.translationMatrix = createTranslationMatrix(x: -0.75, y: -0.75, z: 0)
        circleNormal.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: circleNormal)
        
        let circleWire = NRegularPolygon(numOfSides: 30, color: simd_float4(0.0, 1.0, 0.0, 1.0))
        circleWire.triangleFillMode = .lines
        circleWire.translationMatrix = createTranslationMatrix(x: 0.75, y: -0.75, z: 0)
        circleWire.scaleMatrix = createScaleMatrix(x: 0.5, y: 0.5, z: 0)
        scene.addChild(node: circleWire)
        
        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
