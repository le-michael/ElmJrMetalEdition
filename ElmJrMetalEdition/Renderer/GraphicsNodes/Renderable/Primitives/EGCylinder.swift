//
//  EGCylinder.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//
import MetalKit

class EGCylinder: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(
                cylinderWithExtent: [0.5, 1, 0.5],
                segments: [25, 25],
                inwardNormals: false,
                topCap: true,
                bottomCap: true,
                geometryType: .triangles,
                allocator: allocator
            )
        })
    }
    
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(
                cylinderWithExtent: extent,
                segments: segments,
                inwardNormals: false,
                topCap: true,
                bottomCap: true,
                geometryType: .triangles,
                allocator: allocator
            )
        })
    }
}
