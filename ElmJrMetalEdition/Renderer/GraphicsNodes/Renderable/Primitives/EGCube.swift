//
//  EGCube.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGCube: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(boxWithExtent: [1, 1, 1],
                    segments: [1, 1, 1],
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)

        })
    }

    init(extent: simd_float3) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(boxWithExtent: extent,
                    segments: [1, 1, 1],
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)

        })
    }
}
