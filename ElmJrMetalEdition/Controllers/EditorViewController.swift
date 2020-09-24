//
//  EditorViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

class EditorViewController : UIViewController {
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
        mtkView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        
        mtkView.device = MTLCreateSystemDefaultDevice()
        device = mtkView.device
        
        mtkView.clearColor = MTLClearColorMake(0.1, 0.8, 0.2, 1.0)
        
        renderer = Renderer(device: device)
        mtkView.delegate = renderer
    }    
}
