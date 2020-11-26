//
//  Line2D.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import GLKit
import simd

class Line2D: Renderable {
    init(p0: simd_float3, p1: simd_float3, size: Float) {
        let bufferData = lineBufferData(p0: p0, p1: p1, size: size)
        super.init(mesh: Mesh(bufferData))
    }
}
