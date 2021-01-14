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
        // Add empty light to prevent crash
        if lights.count == 0 {
            lights.append(Light())
        }
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
