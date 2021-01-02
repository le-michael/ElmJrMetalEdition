//
//  EGCone.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGCone: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(coneWithExtent: [1, 1, 1],
                    segments: [20, 20],
                    inwardNormals: false,
                    cap: true,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}
