//
//  Plane.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class Plane: Renderable {
    init(color: simd_float4) {
        let bufferData = planeBufferData()
        let vertices = bufferData.vertexPositions.map {
            Vertex(Position: $0, Color: color)
        }
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
