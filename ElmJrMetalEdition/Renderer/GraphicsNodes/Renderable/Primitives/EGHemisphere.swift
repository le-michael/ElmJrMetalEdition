//
//  EGHemisphere.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//
import MetalKit

class EGHemisphere: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(hemisphereWithExtent: [0.75, 0.75, 0.75],
                    segments: [25, 25],
                    inwardNormals: false,
                    cap: true,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}
