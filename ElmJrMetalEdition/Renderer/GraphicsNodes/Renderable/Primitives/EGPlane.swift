//
//  EGPlane.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGPlane: EGPrimitive {
    init() {
        let bufferData = EGBufferDataBuilder.createPlaneBufferData()
        super.init(mesh: EGMesh(bufferData))
    }
}
