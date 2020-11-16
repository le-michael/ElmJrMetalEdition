//
//  Triangle.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

// MARK: Triangle Class

class Triangle : Node {
    let device: MTLDevice
    let indicies: [UInt16] = [0, 1, 2]
    
    var verticies: [Vertex]
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    init(color: simd_float4, device: MTLDevice) {
        verticies = [
            Vertex(Position: simd_float3(0, 0.25, 0), Color: color),
            Vertex(Position: simd_float3(0.5, -0.5, 0), Color: color),
            Vertex(Position: simd_float3(-0.5, -0.5, 0), Color: color),
        ]
        self.device = device
        super.init()
        buildBuffers()
    }
    
    private func buildBuffers() {
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
    
    override func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState) {
        guard let indexBuffer = indexBuffer else { return }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: 0
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
