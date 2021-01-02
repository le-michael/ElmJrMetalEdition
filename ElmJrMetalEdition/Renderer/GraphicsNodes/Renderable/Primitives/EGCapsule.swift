//
//  EGCapsule.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGCapsule: EGPrimitive3D {
    init() {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(capsuleWithExtent: [0.5, 1.5, 0.5],
                    cylinderSegments: [10, 10],
                    hemisphereSegments: 10,
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}
