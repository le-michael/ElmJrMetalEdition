//
//  TriangleRenderController.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import MetalKit
import UIKit

func transpile(data: [TriangleEditNode]) -> [NRegularPolygon] {
    var triangleNodes = [NRegularPolygon]()

    for triangle in data {
        let tempTriangle = NRegularPolygon(numOfSides: 3, color: simd_float4(triangle.color.r, triangle.color.g, triangle.color.b, triangle.color.a))
        tempTriangle.rotationMatrix = createZRotationMatrix(degrees: triangle.rotation)
        tempTriangle.translationMatrix = createTranslationMatrix(x: triangle.xPos, y: triangle.yPos, z: 0)
        tempTriangle.scaleMatrix = createScaleMatrix(x: triangle.size, y: triangle.size, z: 0)
        triangleNodes.append(tempTriangle)
    }

    return triangleNodes
}

private func getColor(color: ColorEditNode) -> simd_float4 {
    return simd_float4(color.r, color.b, color.g, color.a)
}
