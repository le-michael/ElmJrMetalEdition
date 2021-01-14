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
    var sceneProps = EGSceneProps()
    var fps: Float = 60

    var camera = EGCamera()
    var lights = [Light]()

    override init() {
        super.init()
        // TODO: Remove this
        lights.append(
            Light(
                position: [1, 2, 2],
                color: [0.7, 0.7, 0.7],
                intensity: 1,
                type: Directional
            )
        )
        
        lights.append(
            Light(
                position: [1, -2, -2],
                color: [0.7, 0.7, 0.7],
                intensity: 0.5,
                type: Directional
            )
        )

    }

    func setDrawableSize(size: CGSize) {
        drawableSize = size
        sceneProps.projectionMatrix = matrix_float4x4(
            projectionFov: Float(65).degreesToRadians,
            near: 0.1,
            far: 300,
            aspect: Float(size.width / size.height)
        )
    }

    override func createBuffers(device: MTLDevice) {
        camera.transform.checkIfStatic()
        for child in children {
            child.createBuffers(device: device)
        }
    }

    private func updateSceneProps() {
        sceneProps.time += 1.0 / fps
        sceneProps.viewMatrix = camera.viewMatrix(sceneProps: sceneProps)
        sceneProps.lights = lights
        sceneProps.cameraPosition = camera.position
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
