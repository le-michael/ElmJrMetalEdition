//
//  EGPipelineStateBuilder.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGPipelineStateBuilder {
    static func createPrimitivePipelineState(library: MTLLibrary, device: MTLDevice, view: MTKView) throws -> MTLRenderPipelineState {
        let primitiveVertexFunction = library.makeFunction(name: "primitive_vertex_shader")
        let primitiveFragmentFunction = library.makeFunction(name: "primitive_fragment_shader")
        
        let primitivePipelineDescriptor = MTLRenderPipelineDescriptor()
        primitivePipelineDescriptor.vertexFunction = primitiveVertexFunction
        primitivePipelineDescriptor.fragmentFunction = primitiveFragmentFunction
        primitivePipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        let primitiveVertexDescriptor = MTLVertexDescriptor()
        primitiveVertexDescriptor.attributes[0].format = .float3
        primitiveVertexDescriptor.attributes[0].offset = 0
        primitiveVertexDescriptor.attributes[0].bufferIndex = 0
        
        primitiveVertexDescriptor.layouts[0].stride = MemoryLayout<EGVertex.Primitive>.stride
        
        primitivePipelineDescriptor.vertexDescriptor = primitiveVertexDescriptor
        primitivePipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        let primitivePipelineState = try device.makeRenderPipelineState(descriptor: primitivePipelineDescriptor)
        return primitivePipelineState
    }
    
    static func createBezierPipelineState(library: MTLLibrary, device: MTLDevice, view: MTKView) throws -> MTLRenderPipelineState {
        let bezierVertexFunction = library.makeFunction(name: "bezier_vertex_shader")
        let primitiveFragmentFunction = library.makeFunction(name: "primitive_fragment_shader")
        
        let bezierPipelineDescriptor = MTLRenderPipelineDescriptor()
        bezierPipelineDescriptor.vertexFunction = bezierVertexFunction
        bezierPipelineDescriptor.fragmentFunction = primitiveFragmentFunction
        bezierPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
    
        let bezierVertexDescriptor = MTLVertexDescriptor()
        bezierVertexDescriptor.attributes[0].format = .float3
        bezierVertexDescriptor.attributes[0].offset = 0
        bezierVertexDescriptor.attributes[0].bufferIndex = 0
        
        bezierVertexDescriptor.attributes[1].format = .float
        bezierVertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.stride
        bezierVertexDescriptor.attributes[1].bufferIndex = 0
        
        bezierVertexDescriptor.layouts[0].stride = MemoryLayout<EGVertex.Bezier>.stride
        
        bezierPipelineDescriptor.vertexDescriptor = bezierVertexDescriptor
        bezierPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let bezierPipelineState = try device.makeRenderPipelineState(descriptor: bezierPipelineDescriptor)
        return bezierPipelineState
    }
}
