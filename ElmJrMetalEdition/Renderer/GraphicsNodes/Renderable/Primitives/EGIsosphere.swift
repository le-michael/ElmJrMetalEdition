//
//  EGIsosphere.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-08.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

class EGIsosphere: EGPrimitive {
    init() {
        let bufferData = EGBufferDataBuilder.createIsosphereBufferData()
        super.init(mesh: EGMesh(bufferData))
    }
}
