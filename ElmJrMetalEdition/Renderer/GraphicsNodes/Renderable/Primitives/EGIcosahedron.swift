//
//  EGIcosahedron.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGIcosahedron: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(icosahedronWithExtent: [0.75, 0.75, 0.75],
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}
