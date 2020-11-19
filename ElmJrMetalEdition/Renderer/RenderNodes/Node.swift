//
//  Node.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Node {
    var children: [Node] = []

    init() {}

    func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {}

    func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, sceneProps: SceneProps) {}
    
    func createBuffers(device: MTLDevice) {}

    func addChild(node: Node) {
        children.append(node)
    }
}
