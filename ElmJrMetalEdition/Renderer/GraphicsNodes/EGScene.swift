//
//  EGScene.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGScene: EGGraphicsNode {
    let device: MTLDevice
    var drawableSize: CGSize?
    var sceneProps: EGSceneProps!
    var fps: Float

    init(device: MTLDevice) {
        self.device = device
        fps = 60
        super.init()
        initSceneProps()
    }

    func setDrawableSize(size: CGSize) {
        drawableSize = size
        sceneProps?.projectionMatrix = EGMatrixBuilder.createProjectionMatrix(
            fovDegrees: 65,
            aspect: Float(size.width / size.height),
            nearZ: 0.1,
            farZ: 200
        )
    }

    private func initSceneProps() {
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }

    override func add(_ node: EGGraphicsNode) {
        super.add(node)
        node.createBuffers(device: device)
    }

    func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        sceneProps.time += 1.0 / fps
        for child in children {
            child.draw(
                commandEncoder: commandEncoder,
                pipelineState: pipelineState,
                sceneProps: sceneProps
            )
        }
    }
}
