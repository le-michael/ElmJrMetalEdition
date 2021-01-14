//
//  EGModel.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-13.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGModel: EGPrimitive3D {
    var name: String
    init(modelName name: String) {
        self.name = name
        super.init(mdlMeshFunction: { allocator in
            guard let assetURL = Bundle.main.url(forResource: name, withExtension: nil) else {
                fatalError("Cannot find model '\(name)'")
            }
            
            let asset = MDLAsset(
                url: assetURL,
                vertexDescriptor: EGVertexDescriptor.primitive,
                bufferAllocator: allocator
            )
            
            return asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        })
    }
}
