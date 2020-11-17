//
//  TriangleRenderController.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import UIKit
import MetalKit

func parse(data: [TriangleEditNode], device: MTLDevice ) -> [Triangle] {
    var triangleNodes = [Triangle]()

    for triangle in data {
        triangleNodes.append(Triangle(
                            xPos: triangle.xPos,
                            yPos: triangle.yPos,
                            size: triangle.size,
                            color: getColor(color: triangle.color),
                            device: device))
    }
    
    return triangleNodes
}

private func getColor(color: ColorEditNode) ->simd_float4 {
    return simd_float4(color.r, color.b, color.g, color.a)
}
