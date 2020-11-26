//
//  RGNode.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class RGNode {
    var children: [RGNode] = []

    init() {}

    func draw(commandEncoder: MTLRenderCommandEncoder,
              pipelineState: MTLRenderPipelineState, sceneProps: SceneProps) {}

    func createBuffers(device: MTLDevice) {}

    func add(_ node: RGNode) {
        children.append(node)
    }
}
