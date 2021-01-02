//
//  EVGraphicsView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

class EVGraphicsView: UIView {
    
    let mtkView = MTKView()

    var device: MTLDevice!
    var renderer: MTKViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mtkView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        mtkView.device = MTLCreateSystemDefaultDevice()
        device = mtkView.device

        let scene = EGDemoScenes.cubeTunnel()

        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        renderer = EGRenderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
