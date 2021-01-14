//
//  EGVertexDescriptor.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-13.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import ModelIO

class EGVertexDescriptor {
    static var primitive: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: offset,
            bufferIndex: 0
        )
        offset += MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: 0
        )
        offset += MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }()
}
