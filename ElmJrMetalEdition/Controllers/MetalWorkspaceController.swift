//
//  MetalWorkspaceController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-10-09.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

class MetalWorkspaceController : UIViewController {
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
        let triangle1 = Triangle(
            xPos: 0.5,
            yPos: 0.5,
            size: 0.5,
            color: simd_float4(0.0, 0.0, 1.0, 1.0),
            device: device
        )
        scene.addChild(node: triangle1)
        let triangle2 = Triangle(
            xPos: -0.4,
            yPos: -0.4,
            size: 0.25,
            color: simd_float4(0.0, 1.0, 0.0, 1.0),
            device: device
        )
        scene.addChild(node: triangle2)
        
        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
}
