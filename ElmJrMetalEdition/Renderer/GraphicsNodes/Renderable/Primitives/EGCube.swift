//
//  Cube.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-04.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

class EGCube: EGPrimitive {
    init() {
        let bufferData = EGBufferDataBuilder.createCubeBufferData()
        super.init(mesh: EGMesh(bufferData))
    }
}
