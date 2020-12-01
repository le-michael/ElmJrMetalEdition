//
//  EGGraphicsNode.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGGraphicsNode {
    var children: [EGGraphicsNode] = []

    func draw(commandEncoder: MTLRenderCommandEncoder,
              pipelineStates: [EGPipelineStates: MTLRenderPipelineState],
              sceneProps: EGSceneProps) {}

    func createBuffers(device: MTLDevice) {}

    func add(_ node: EGGraphicsNode) {
        children.append(node)
    }
}
