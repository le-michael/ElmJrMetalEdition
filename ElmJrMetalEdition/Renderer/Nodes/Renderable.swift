//
//  Renderable.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Renderable: Node {
    var mesh: Mesh
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var primativeRenderType: MTLPrimitiveType
    
    var translationMatrix = matrix_identity_float4x4
    var rotationMatrix = matrix_identity_float4x4
    var scaleMatrix = matrix_identity_float4x4
    var modelConstants = ModelConstants()
    
    init(mesh: Mesh) {
        self.mesh = mesh
        self.primativeRenderType = mesh.showWireFrame ? .lineStrip : .triangle
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(
            bytes: mesh.vertices,
            length: mesh.vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: mesh.indices,
            length: mesh.indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }

    private func updateModelViewMatrix(sceneProps: SceneProps) {
        let transformationMatrix = translationMatrix * rotationMatrix * scaleMatrix
        modelConstants.modelViewMatrix = sceneProps.projectionMatrix * sceneProps.viewMatrix * transformationMatrix
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, sceneProps: SceneProps)
    {
        guard let indexBuffer = indexBuffer,
              let vertexBuffer = vertexBuffer else { return }
        
        updateModelViewMatrix(sceneProps: sceneProps)
      
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
            type: primativeRenderType,
            indexCount: mesh.indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }
}