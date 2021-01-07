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
    }

    override func createBuffers(device: MTLDevice) {
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let mdlMesh = mdlMeshFunction(allocator) else {
            return
        }

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
              let mtkMesh = mtkMesh,
              let submesh = mtkMesh.submeshes.first else { return }

        updateVertexUniforms(sceneProps)

        commandEncoder.setRenderPipelineState(pipeline)
        commandEncoder.setVertexBuffer(mtkMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&vertexUniforms,
                                      length: MemoryLayout<EGVertexUniforms.Primitive>.stride,
                                      index: 1)
        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setCullMode(.front)
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: submesh.indexCount,
                                             indexType: submesh.indexType,
                                             indexBuffer: submesh.indexBuffer.buffer,
                                             indexBufferOffset: submesh.indexBuffer.offset)

        if drawOutline {
            vertexUniforms.color = outlineColor

            commandEncoder.setRenderPipelineState(pipeline)
            commandEncoder.setVertexBuffer(mtkMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            commandEncoder.setVertexBytes(&vertexUniforms,
                                          length: MemoryLayout<EGVertexUniforms.Primitive>.stride,
                                          index: 1)
            commandEncoder.setTriangleFillMode(.lines)
            commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                 indexCount: submesh.indexCount,
                                                 indexType: submesh.indexType,
                                                 indexBuffer: submesh.indexBuffer.buffer,
                                                 indexBufferOffset: submesh.indexBuffer.offset)
        }
    }
}

class EGSphere: EGPrimitive3D {
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(sphereWithExtent: extent,
                    segments: segments,
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}

class EGCube: EGPrimitive3D {
    init(extent: simd_float3) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(boxWithExtent: extent,
                    segments: [1, 1, 1],
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)

        })
    }
}

class EGCone: EGPrimitive3D {
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(coneWithExtent: extent,
                    segments: segments,
                    inwardNormals: false,
                    cap: true,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}

class EGCapsule: EGPrimitive3D {
    init(extent: simd_float3, cylinderSegments: simd_uint2, hemisphereSegments: Int32) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(capsuleWithExtent: extent,
                    cylinderSegments: cylinderSegments,
                    hemisphereSegments: hemisphereSegments,
                    inwardNormals: false,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}

class EGHemisphere: EGPrimitive3D {
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(hemisphereWithExtent: extent,
                    segments: segments,
                    inwardNormals: false,
                    cap: true,
                    geometryType: .triangles,
                    allocator: allocator)
        })
    }
}

class EGCylinder: EGPrimitive3D {
    init(extent: simd_float3, segments: simd_uint2) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(
                cylinderWithExtent: extent,
                segments: segments,
                inwardNormals: false,
                topCap: true,
                bottomCap: true,
                geometryType: .triangles,
                allocator: allocator
            )
        })
    }
}

class EGIcosahedron: EGPrimitive3D {
    init(extent: simd_float3) {
        super.init(mdlMeshFunction: { allocator in
            MDLMesh(
                icosahedronWithExtent: extent,
                inwardNormals: false,
                geometryType: .triangles,
                allocator: allocator
            )
        })
    }
}
