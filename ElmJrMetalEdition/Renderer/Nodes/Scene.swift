//
//  Scene.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Scene: Node {
    let device: MTLDevice
    var drawableSize: CGSize?
    var sceneProps: SceneProps!

    init(device: MTLDevice) {
        self.device = device
        super.init()
        initSceneProps()
    }

    func setDrawableSize(size: CGSize) {
        drawableSize = size
        sceneProps?.projectionMatrix = createProjectionMatrix(
            fovDegrees: 65,
            aspect: Float(size.width / size.height),
            nearZ: 0.1,
            farZ: 100
        )
    }

    private func initSceneProps() {
        sceneProps = SceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4
        )
    }

    override func addChild(node: Node) {
        super.addChild(node: node)
        node.createBuffers(device: device)
    }

    override func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        for child in children {
            child.draw(commandEncoder: commandEncoder, pipelineState: pipelineState, sceneProps: sceneProps)
        }
    }
}
