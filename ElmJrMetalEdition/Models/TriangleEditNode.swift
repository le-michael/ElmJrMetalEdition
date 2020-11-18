//
//  TriangleEditNode.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import MetalKit

var mockData : [TriangleEditNode] = [
    TriangleEditNode(color: ColorEditNode(r: 0.0, g: 0.0, b: 1.0, a: 1.0),
                     rotationMatrix: createZRotationMatrix(degrees: 180)),
    
    TriangleEditNode(color: ColorEditNode(r: 1.0, g: 0.0, b: 1.0, a: 1.0),
                     translationMatrix: createTranslationMatrix(x: -0.5, y: Float(sqrt(3)/2), z: 0)),
    
    TriangleEditNode(color: ColorEditNode(r: 0.0, g: 1.0, b: 1.0, a: 1.0),
                     translationMatrix: createTranslationMatrix(x: 0.5, y: -Float(sqrt(3)/2), z: 0)),
    
    TriangleEditNode(color: ColorEditNode(r: 0.0, g: 1.0, b: 0.0, a: 1.0),
                     translationMatrix: createTranslationMatrix(x: 0.5, y: -Float(sqrt(3)/2), z: 0),
                     rotationMatrix: createZRotationMatrix(degrees: 180)),
    
    TriangleEditNode(color: ColorEditNode(r: 1.0, g: 0.0, b: 0.0, a: 1.0),
                     translationMatrix: createTranslationMatrix(x: 0.25, y: -0.5, z: 0),
                     rotationMatrix: createZRotationMatrix(degrees: 45),
                     scaleMatrix: createScaleMatrix(x: 0.5, y: 0.5, z: 0)),
]

class TriangleEditNode {
    var color: ColorEditNode;
    var translationMatrix: simd_float4x4;
    var rotationMatrix: simd_float4x4;
    var scaleMatrix: simd_float4x4;
    
    init(color: ColorEditNode,
         translationMatrix: simd_float4x4 = matrix_identity_float4x4,
         rotationMatrix: simd_float4x4 = matrix_identity_float4x4,
         scaleMatrix: simd_float4x4 = matrix_identity_float4x4
        ) {
        self.color = color;
        self.translationMatrix = translationMatrix;
        self.rotationMatrix = rotationMatrix;
        self.scaleMatrix = scaleMatrix;
    }
}


