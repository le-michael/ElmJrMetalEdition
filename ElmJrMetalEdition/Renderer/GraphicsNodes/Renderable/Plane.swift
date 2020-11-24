//
//  Plane.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class Plane: Renderable {
    init() {
        let bufferData = planeBufferData()
        let vertices = bufferData.vertexPositions.map {
            Vertex(position: $0)
        }
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
