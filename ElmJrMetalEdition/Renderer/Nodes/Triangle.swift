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
    let device: MTLDevice
    let indicies: [UInt16] = [0, 1, 2]
    
    var verticies: [Vertex]
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    init(xPos: Float, yPos: Float, size: Float, color: simd_float4, device: MTLDevice) {
        verticies = [
            Vertex(Position: simd_float3(xPos, yPos+size/2, 0), Color: color),
            Vertex(Position: simd_float3(xPos+size, yPos-size, 0), Color: color),
            Vertex(Position: simd_float3(xPos-size, yPos-size, 0), Color: color),
        ]
        self.device = device
        super.init()
        initBuffers()
    }
    
    private func initBuffers() {
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
