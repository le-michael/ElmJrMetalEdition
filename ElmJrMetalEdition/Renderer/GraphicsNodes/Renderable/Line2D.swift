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
        let bufferData = planeBufferData()
        
        let magnitude = simd_distance(p0, p1)
        bufferData.applyTransform(transformMatrix: createScaleMatrix(x: size, y: magnitude, z: 1))
        
        let v = p1 - p0
        let angle = -atan(v.x/v.y)
        bufferData.applyTransform(transformMatrix: createZRotationMatrix(radians: angle))
        
        let midPoint = p0 + v/2
        bufferData.applyTransform(transformMatrix: createTranslationMatrix(x: midPoint.x, y: midPoint.y, z: midPoint.z))
        
        let vertices = bufferData.vertexPositions.map {
            Vertex(position: $0)
        }
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
