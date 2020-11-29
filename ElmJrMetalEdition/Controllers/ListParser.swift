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

func transpile(data: [TriangleEditNode]) -> [EGRegularPolygon] {
    var triangleNodes = [EGRegularPolygon]()

    for _ in data {
        let tempTriangle = EGRegularPolygon(3)
        // tempTriangle.rotationMatrix = createZRotationMatrix(degrees: triangle.rotation)
        //tempTriangle.translationMatrix = createTranslationMatrix(x: triangle.xPos, y: triangle.yPos, z: 0)
        //tempTriangle.scaleMatrix = createScaleMatrix(x: triangle.size, y: triangle.size, z: 0)
        triangleNodes.append(tempTriangle)
    }

    return triangleNodes
}

private func getColor(color: ColorEditNode) -> simd_float4 {
    return simd_float4(color.r, color.b, color.g, color.a)
}
