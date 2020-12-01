//
//  EGRegularPolygon.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGRegularPolygon: EGRenderable {
    init(_ numOfSides: Int) {
        let bufferData = EGBufferDataBuilder.createRegularPolygonBufferData(numOfSides)
        super.init(mesh: EGMesh(bufferData))
    }
}
