//
//  RegularPolygon.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class RegularPolygon: Renderable {
    init(_ numOfSides: Int) {
        let bufferData = regularPolygonBufferData(numOfSides)
        let vertices = bufferData.vertexPositions.map {
            Vertex(position: $0)
        }
        
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
