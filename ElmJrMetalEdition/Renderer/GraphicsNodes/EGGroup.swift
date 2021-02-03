//
//  EGGroup.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-02-01.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGGroup: EGGraphicsNode {
    var transform = EGTransformProperty()

    override func createBuffers(device: MTLDevice) {
        transform.checkIfStatic()
        for child in children {
            child.createBuffers(device: device)
        }
    }

    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineStates: EGPipelineState,
                       sceneProps: EGSceneProps)
    {
        let parentOld = sceneProps.parentTransform
        sceneProps.parentTransform *= transform.transformationMatrix(sceneProps)

        for child in children {
            child.draw(
                commandEncoder: commandEncoder,
                pipelineStates: pipelineStates,
                sceneProps: sceneProps
            )
        }

        sceneProps.parentTransform = parentOld
    }
}
