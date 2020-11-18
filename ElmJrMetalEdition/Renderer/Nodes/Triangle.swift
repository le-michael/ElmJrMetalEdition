//
//  Triangle.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

// MARK: Triangle Class

class Triangle: Node {
    let indicies: [UInt16] = [0, 1, 2]
    
    var verticies: [Vertex]
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?

    var modelConstants = ModelConstants()
    
    var translationMatrix = matrix_identity_float4x4
    var rotationMatrix = matrix_identity_float4x4
    var scaleMatrix = matrix_identity_float4x4
    
    init(color: simd_float4) {
        verticies = [
            Vertex(Position: simd_float3(1/2, 1 * (sqrt(3)/2), 0), Color: color),
            Vertex(Position: simd_float3(1, 0, 0), Color: color),
            Vertex(Position: simd_float3(0, 0, 0), Color: color),
        ]
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {

        vertexBuffer = device.makeBuffer(
            bytes: verticies, length: verticies.count * MemoryLayout<Vertex>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: indicies,
            length: indicies.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }
    
    private func transformationMatrix() -> matrix_float4x4 {
        return translationMatrix * rotationMatrix * scaleMatrix
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, sceneProps: SceneProps) {
        guard let indexBuffer = indexBuffer,
              let vertexBuffer = vertexBuffer else { return }
        
        let modelViewMatrix = sceneProps.viewMatrix * transformationMatrix()
        modelConstants.modelViewMatrix = sceneProps.projectionMatrix * modelViewMatrix
      
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
        )
        commandEncoder.setVertexBytes(
            &modelConstants,
            length: MemoryLayout<ModelConstants>.stride,
            index: 1
        )
        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indicies.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }
}
