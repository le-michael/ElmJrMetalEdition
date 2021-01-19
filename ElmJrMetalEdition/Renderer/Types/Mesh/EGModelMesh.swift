//
//  EGModelMesh.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-18.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGModelMesh {
    var mtkMesh: MTKMesh
    var submeshes: [EGModelSubmesh]

    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
        self.mtkMesh = mtkMesh
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
            EGModelSubmesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
        }
    }
}

class EGModelSubmesh {
    var mdlSubmesh: MDLSubmesh
    var mtkSubmesh: MTKSubmesh

    var color = EGColorProperty()

    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        self.mdlSubmesh = mdlSubmesh
        self.mtkSubmesh = mtkSubmesh

        guard
            let material = mdlSubmesh.material,
            let mdlBaseColor = material.property(with: MDLMaterialSemantic.baseColor)
        else {
            return
        }

        color.set(color: mdlBaseColor.float3Value)
    }
}
