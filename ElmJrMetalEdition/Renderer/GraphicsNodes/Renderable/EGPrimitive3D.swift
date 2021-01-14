//
//  EGPrimitive3D.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-01.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit

class EGPrimitive3D: EGPrimitive {
    var mtkMesh: MTKMesh?
    var mdlMeshFunction: (MTKMeshBufferAllocator) -> MDLMesh?

    init(mdlMeshFunction: @escaping (MTKMeshBufferAllocator) -> MDLMesh) {
        self.mdlMeshFunction = mdlMeshFunction
        super.init()
        surfaceType = Lit
        fragmentUniforms.materialShine = 32
        fragmentUniforms.materialSpecularColor = [0.6, 0.6, 0.6]
    }

    override func createBuffers(device: MTLDevice) {
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let mdlMesh = mdlMeshFunction(allocator) else {
            return
        }
        mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 1)
        transform.checkIfStatic()
        color.checkIfStatic()

        do {
            mtkMesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch {
            fatalError("Unable to create buffers for shape 3D: \(error.localizedDescription)")
        }
    }

    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineStates: EGPipelineState,
                       sceneProps: EGSceneProps)
    {
        guard let pipeline = pipelineStates.states[.primitive3D],
              let mtkMesh = mtkMesh else { return }

        updateVertexUniforms(sceneProps)
        commandEncoder.setRenderPipelineState(pipeline)

        commandEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<PrimitiveFragmentUniforms>.stride,
            index: Int(BufferFragmentUniforms.rawValue)
        )

        commandEncoder.setFragmentBytes(
            sceneProps.lights,
            length: MemoryLayout<Light>.stride * sceneProps.lights.count,
            index: Int(BufferLights.rawValue)
        )

        commandEncoder.setVertexBuffer(mtkMesh.vertexBuffers[0].buffer, offset: 0, index: Int(BufferVertex.rawValue))
        commandEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<PrimitiveVertexUniforms>.stride,
            index: Int(BufferVertexUniforms.rawValue)
        )

        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setCullMode(.front)
        for submesh in mtkMesh.submeshes {
            commandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
    }
}

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

class EGSphere: EGModel {
    init() {
        super.init(modelName: "sphere.obj")
    }
}

class EGCube: EGModel {
    init() {
        super.init(modelName: "cube.obj")
    }
}

class EGCone: EGModel {
    init() {
        super.init(modelName: "cone.obj")
    }
}

class EGCapsule: EGModel {
    init() {
        super.init(modelName: "capsule.obj")
    }
}

class EGCylinder: EGModel {
    init() {
        super.init(modelName: "cylinder.obj")
    }
}

class EGMonkey: EGModel {
    init() {
        super.init(modelName: "monkey.obj")
    }
}

class EGRing: EGModel {
    init() {
        super.init(modelName: "ring.obj")
    }
}
