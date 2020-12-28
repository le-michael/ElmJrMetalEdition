//
//  EGRenderable.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGPrimitive: EGGraphicsNode {
    var mesh: EGMesh
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var triangleFillMode: MTLTriangleFillMode = .fill
    var drawOutline: Bool = false
    var outlineColor = simd_float4(0, 0, 0, 1)
    
    var vertexUniforms = EGVertexUniforms.Primitive()
    var transform = EGTransformProperty()
    var color = EGColorProperty()
    
    init(mesh: EGMesh) {
        self.mesh = mesh
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {
        transform.checkIfStatic()
        color.checkIfStatic()
        vertexBuffer = device.makeBuffer(
            bytes: mesh.vertices,
            length: mesh.vertices.count * MemoryLayout<EGVertex.Primitive>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: mesh.indices,
            length: mesh.indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }

    private func updateVertexUniforms(_ sceneProps: EGSceneProps) {
        let transformationMatrix = transform.getTransformationMatrix(sceneProps)
        
        vertexUniforms.modelViewMatrix = sceneProps.projectionMatrix
            * sceneProps.viewMatrix
            * transformationMatrix
        
        let colorValue = color.evaluate(sceneProps)
        vertexUniforms.color = colorValue
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineStates: [EGPipelineStates: MTLRenderPipelineState],
                       sceneProps: EGSceneProps)
    {
        guard let indexBuffer = indexBuffer,
              let pipeline = pipelineStates[.PrimitivePipelineState],
              let vertexBuffer = vertexBuffer else { return }
        
        updateVertexUniforms(sceneProps)
      
        commandEncoder.setRenderPipelineState(pipeline)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setCullMode(.front)
        commandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<EGVertexUniforms.Primitive>.stride,
            index: 1
        )
        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: mesh.indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
        
        if drawOutline {
            vertexUniforms.color = outlineColor
            
            commandEncoder.setRenderPipelineState(pipeline)
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setTriangleFillMode(.lines)
            commandEncoder.setVertexBytes(
                &vertexUniforms,
                length: MemoryLayout<EGVertexUniforms.Primitive>.stride,
                index: 1
            )
            commandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: mesh.indices.count,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0
            )
        }
    }
}
