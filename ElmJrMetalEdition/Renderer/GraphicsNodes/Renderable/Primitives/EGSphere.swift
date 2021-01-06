//
//  EGSphere.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-04.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGSphere: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75],
                    segments: [25, 25],
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
    
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(sphereWithExtent: extent,
                    segments: segments,
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}
