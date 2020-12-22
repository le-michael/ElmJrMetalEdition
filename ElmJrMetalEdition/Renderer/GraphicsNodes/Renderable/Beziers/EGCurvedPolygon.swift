//
//  EGCurvedPolygon.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGCurvedPolygon: EGGraphicsNode {
    let mesh: EGBezierMesh
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var triangleFillMode: MTLTriangleFillMode = .fill

    var vertexUniforms = EGVertexUniforms.Bezier()
    var transform = EGTransformProperty()
    var color = EGColorProperty()

    var p0: EGPoint2D
    var p1: EGPoint2D
    var p2: EGPoint2D
    var p3: EGPoint2D

    init(p0: EGPoint2D, p1: EGPoint2D, p2: EGPoint2D, p3: EGPoint2D) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        
        let bufferData = EGBufferDataBuilder.createRegularPolygonBufferData(35)
        self.mesh = EGBezierMesh(bufferData)
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {
        transform.checkIfStatic()
        color.checkIfStatic()
        vertexBuffer = device.makeBuffer(
            bytes: mesh.vertices,
            length: mesh.vertices.count * MemoryLayout<EGVertex.Bezier>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: mesh.indices,
            length: mesh.indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }
    
    private func updateModelConstants(_ sceneProps: EGSceneProps) {
        let transformationMatrx = transform.getTransformationMatrix(sceneProps)
        
        vertexUniforms.modelViewMatrix = sceneProps.projectionMatrix
            * sceneProps.viewMatrix
            * transformationMatrx
        
        let colorValue = color.evaluate(sceneProps)
        vertexUniforms.color = colorValue
        
        vertexUniforms.p0 = p0.evaluate(sceneProps)
        vertexUniforms.p1 = p1.evaluate(sceneProps)
        vertexUniforms.p2 = p2.evaluate(sceneProps)
        vertexUniforms.p3 = p3.evaluate(sceneProps)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineStates: [EGPipelineStates: MTLRenderPipelineState],
                       sceneProps: EGSceneProps)
    {
        guard let indexBuffer = indexBuffer,
              let pipeline = pipelineStates[.BezierPipelineState],
              let vertexBuffer = vertexBuffer else { return }
        
        updateModelConstants(sceneProps)
      
        commandEncoder.setRenderPipelineState(pipeline)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<EGVertexUniforms.Bezier>.stride,
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
