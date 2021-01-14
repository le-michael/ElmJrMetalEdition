//
//  EGRenderable.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGPrimitive: EGGraphicsNode {
    var mesh: EGMesh?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var triangleFillMode: MTLTriangleFillMode = .fill
    
    var vertexUniforms = PrimitiveVertexUniforms()
    var fragmentUniforms = PrimitiveFragmentUniforms()
    
    var transform = EGTransformProperty()
    var color = EGColorProperty()
    
    var surfaceType: SurfaceType = Unlit
    
    override init() { super.init() }
    
    init(mesh: EGMesh) {
        self.mesh = mesh
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {
        guard let mesh = mesh else { return }
        
        transform.checkIfStatic()
        color.checkIfStatic()
        
        vertexBuffer = device.makeBuffer(bytes: mesh.vertices,
                                         length: mesh.vertices.count * MemoryLayout<EGVertex.Primitive>.stride,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: mesh.indices,
                                        length: mesh.indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
    }

    func updateUniforms(_ sceneProps: EGSceneProps) {
        let transformationMatrix = transform.transformationMatrix(sceneProps)
        vertexUniforms.modelMatrix = transformationMatrix
        vertexUniforms.viewMatrix = sceneProps.viewMatrix
        vertexUniforms.projectionMatrix = sceneProps.projectionMatrix
        vertexUniforms.normalMatrix = transformationMatrix.upperLeft
        
        let colorValue = color.evaluate(sceneProps)
        vertexUniforms.color = colorValue
        
        fragmentUniforms.surfaceType = surfaceType
        fragmentUniforms.lightCount = UInt32(sceneProps.lights.count)
        fragmentUniforms.cameraPosition = sceneProps.cameraPosition
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineStates: EGPipelineState,
                       sceneProps: EGSceneProps)
    {
        guard let indexBuffer = indexBuffer,
              let pipeline = pipelineStates.states[.primitive],
              let vertexBuffer = vertexBuffer,
              let mesh = mesh else { return }
        
        updateUniforms(sceneProps)
      
        commandEncoder.setRenderPipelineState(pipeline)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index:  Int(BufferVertex.rawValue))
        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setVertexBytes(&vertexUniforms,
                                      length: MemoryLayout<PrimitiveVertexUniforms>.stride,
                                      index: Int(BufferVertexUniforms.rawValue))
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: mesh.indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
}

class EGRegularPolygon: EGPrimitive {
    init(_ numOfSides: Int) {
        let bufferData = EGBufferDataBuilder.createRegularPolygonBufferData(numOfSides)
        super.init(mesh: EGMesh(bufferData))
    }
}

class EGPlane: EGPrimitive {
    override init() {
        let bufferData = EGBufferDataBuilder.createPlaneBufferData()
        super.init(mesh: EGMesh(bufferData))
    }
}

class EGLine2D: EGPrimitive {
    init(p0: simd_float3, p1: simd_float3, size: Float) {
        let bufferData = EGBufferDataBuilder.createLine2DBufferData(p0: p0, p1: p1, size: size)
        super.init(mesh: EGMesh(bufferData))
    }
}
