//
//  MeshHelpers.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

func nRegularPolygonBufferData(numOfSides n: Int, wired: Bool = true) -> (vertexPositions: [simd_float3], indices: [UInt16]) {
    let thetaS: Float = 2 * Float.pi / Float(n)
    var vertexPositions: [simd_float3] = []
    var indices: [UInt16] = []
    
    assert(n >= 3, "NRegualaryPolygon must have atleast 3 sides")
    
    for k in 0 ... n - 1 {
        let r: Float = 1.0
        let theta = Float(k) * thetaS - (thetaS / 2) - (Float.pi / 2)
        let x: Float = r * cos(theta)
        let y: Float = r * sin(theta)
        vertexPositions.append(simd_float3(x, y, 0))
    }
    
    for k in 1 ... n - 2 {
        indices.append(0)
        indices.append(UInt16(k))
        indices.append(UInt16(k + 1))
        if wired {
            indices.append(UInt16(0))
        }
    }
    
    return (vertexPositions, indices)
}
