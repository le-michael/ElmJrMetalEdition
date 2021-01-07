//
//  EGScene.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGScene: EGGraphicsNode {
    var drawableSize: CGSize?
    var sceneProps: EGSceneProps
    var fps: Float = 60
    var camera: EGCamera?

    override init() {
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
        super.init()
    }

    func setDrawableSize(size: CGSize) {
        drawableSize = size
        sceneProps.projectionMatrix = EGMatrixBuilder.createProjectionMatrix(
            fovDegrees: 65,
            aspect: Float(size.width / size.height),
            nearZ: 0.1,
            farZ: 300
        )
    }

    override func createBuffers(device: MTLDevice) {
        camera?.transform.checkIfStatic()
        for child in children {
            child.createBuffers(device: device)
        }
    }

    private func updateSceneProps() {
        guard let camera = camera else {
            print("Scene is missing a camera")
            return
        }

        sceneProps.time += 1.0 / fps
        sceneProps.viewMatrix = camera.viewMatrix(sceneProps: sceneProps)
    }

    func draw(commandEncoder: MTLRenderCommandEncoder, pipelineStates: EGPipelineState) {
        updateSceneProps()

        for child in children {
            child.draw(commandEncoder: commandEncoder,
                       pipelineStates: pipelineStates,
                       sceneProps: sceneProps)
        }
    }
}
