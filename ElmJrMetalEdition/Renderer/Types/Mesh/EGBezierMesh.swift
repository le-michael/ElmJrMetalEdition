//
//  EGBezierMesh.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGBezierMesh {
    var vertices: [EGBezierVertex]
    var indices: [UInt16]

    init(_ bufferData: EGBufferData) {
        self.indices = bufferData.indices
        self.vertices = bufferData.vertexPositions.enumerated().map { ind, pos in
            let dt = 1.0 / (Float(bufferData.vertexPositions.count) - 1)
            let time = Float(ind) * dt
            return EGBezierVertex(
                position: pos,
                time: time
            )
        }
    }
}
