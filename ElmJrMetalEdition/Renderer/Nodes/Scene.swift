//
//  Scene.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Scene : Node {
    let device : MTLDevice
    
    init(device : MTLDevice) {
        self.device = device
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        for child in children {
            child.draw(commandEncoder: commandEncoder, pipelineState: pipelineState)
        }
    }
}
