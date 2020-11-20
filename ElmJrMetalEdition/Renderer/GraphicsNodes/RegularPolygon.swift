//
//  RegularPolygon.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class RegularPolygon: Renderable {
    init(numOfSides n: Int, color: simd_float4) {
        let bufferData = regularPolygonBufferData(numOfSides: n)
        let vertices = bufferData.vertexPositions.map {
            Vertex(Position: $0, Color: color)
        }
        
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
