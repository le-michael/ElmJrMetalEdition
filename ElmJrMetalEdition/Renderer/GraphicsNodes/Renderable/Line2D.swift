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
    init(p0: simd_float3, p1: simd_float3, color: simd_float4) {
        let bufferData = planeBufferData()
        
        let magnitude = simd_distance(p0, p1)
        bufferData.applyTransform(transformMatrix: createScaleMatrix(x: 0.01, y: magnitude, z: 1))
        
        let v = p1 - p0
        let angle = -atan(v.x/v.y) //atan2(simd_cross(p0, p1).z, simd_dot(p0, p1))//acos(dotProduct / (simd_length(p0) * simd_length(p1)))
        bufferData.applyTransform(transformMatrix: createZRotationMatrix(radians: angle))
        
        let midPoint = p0+v/2
        bufferData.applyTransform(transformMatrix: createTranslationMatrix(x: midPoint.x, y: midPoint.y, z: midPoint.z))
        
        let vertices = bufferData.vertexPositions.map {
            Vertex(Position: $0, Color: color)
        }
        super.init(mesh: Mesh(vertices: vertices, indices: bufferData.indices))
    }
}
