//
//  EGMesh.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

class EGMesh {
    var vertices: [EGVertex.Primitive]
    var indices: [UInt16]

    init(_ bufferData: EGBufferData) {
        self.indices = bufferData.indices
        self.vertices = bufferData.vertexPositions.map {
            EGVertex.Primitive(position: $0)
        }
    }
}
