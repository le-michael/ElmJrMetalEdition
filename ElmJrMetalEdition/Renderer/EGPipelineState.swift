//
//  EGPipelineState.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGPipelineState {
    enum PipelineType {
        case primitive
        case bezier
        case primitive3D
    }
    
    var states = [PipelineType: MTLRenderPipelineState]()
    
    init(device: MTLDevice, view: MTKView) {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Unable to make library")
        }
        
        do {
            try createPrimitivePipelineState(library: library, device: device, view: view)
            try createBezierPipelineState(library: library, device: device, view: view)
            try create3DPipelineStates(library: library, device: device, view: view)
        } catch let error {
            fatalError("Unable to initalize pipeline states: \(error)")
        }
    }
    
    func createPrimitivePipelineState(library: MTLLibrary, device: MTLDevice, view: MTKView) throws {
        let primitiveVertexFunction = library.makeFunction(name: "primitive_vertex_shader")
        let primitiveFragmentFunction = library.makeFunction(name: "primitive_fragment_shader")
        
        let primitivePipelineDescriptor = MTLRenderPipelineDescriptor()
        primitivePipelineDescriptor.vertexFunction = primitiveVertexFunction
        primitivePipelineDescriptor.fragmentFunction = primitiveFragmentFunction
        primitivePipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        let primitiveVertexDescriptor = MTLVertexDescriptor()
        
        // Position
        primitiveVertexDescriptor.attributes[0].format = .float3
        primitiveVertexDescriptor.attributes[0].offset = 0
        primitiveVertexDescriptor.attributes[0].bufferIndex = 0
        
        
        // Normal
        primitiveVertexDescriptor.attributes[1].format = .float3
        primitiveVertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.stride
        primitiveVertexDescriptor.attributes[1].bufferIndex = 0
        
        primitiveVertexDescriptor.layouts[0].stride = MemoryLayout<EGVertex.Primitive>.stride
        
        primitivePipelineDescriptor.vertexDescriptor = primitiveVertexDescriptor
        primitivePipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        let primitivePipelineState = try device.makeRenderPipelineState(descriptor: primitivePipelineDescriptor)
        states[.primitive] = primitivePipelineState
    }
    
    func createBezierPipelineState(library: MTLLibrary, device: MTLDevice, view: MTKView) throws {
        let bezierVertexFunction = library.makeFunction(name: "bezier_vertex_shader")
        let primitiveFragmentFunction = library.makeFunction(name: "primitive_fragment_shader")
        
        let bezierPipelineDescriptor = MTLRenderPipelineDescriptor()
        bezierPipelineDescriptor.vertexFunction = bezierVertexFunction
        bezierPipelineDescriptor.fragmentFunction = primitiveFragmentFunction
        bezierPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
    
        let bezierVertexDescriptor = MTLVertexDescriptor()
        // Position
        bezierVertexDescriptor.attributes[0].format = .float3
        bezierVertexDescriptor.attributes[0].offset = 0
        bezierVertexDescriptor.attributes[0].bufferIndex = 0
        
        // Time
        bezierVertexDescriptor.attributes[1].format = .float
        bezierVertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.stride
        bezierVertexDescriptor.attributes[1].bufferIndex = 0
        
        bezierVertexDescriptor.layouts[0].stride = MemoryLayout<EGVertex.Bezier>.stride
        
        bezierPipelineDescriptor.vertexDescriptor = bezierVertexDescriptor
        bezierPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let bezierPipelineState = try device.makeRenderPipelineState(descriptor: bezierPipelineDescriptor)
        states[.bezier] = bezierPipelineState
    }
    
    func create3DPipelineStates(library: MTLLibrary, device: MTLDevice, view: MTKView) throws {
        let primitiveVertexFunction = library.makeFunction(name: "primitive_vertex_shader")
        let primitiveFragmentFunction = library.makeFunction(name: "primitive_fragment_shader")
        
        let shape3DPipelineDescriptor = MTLRenderPipelineDescriptor()
        shape3DPipelineDescriptor.vertexFunction = primitiveVertexFunction
        shape3DPipelineDescriptor.fragmentFunction = primitiveFragmentFunction
        shape3DPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        shape3DPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0, bufferIndex: 0)
        offset += MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: offset, bufferIndex: 0)
        offset += MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)

        shape3DPipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        states[.primitive3D] = try device.makeRenderPipelineState(descriptor: shape3DPipelineDescriptor)
    }
}
