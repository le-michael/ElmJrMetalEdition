//
//  RegularPolygon.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class RegularPolygon: Renderable {
    init(_ numOfSides: Int) {
        let bufferData = regularPolygonBufferData(numOfSides)
        super.init(mesh: Mesh(bufferData))
    }
}
