//
//  EGCamera.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-06.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import simd

class EGCamera {
    var transform = EGTransformProperty()
    var position = simd_float3(0, 0, 0)

    func viewMatrix(sceneProps: EGSceneProps) -> matrix_float4x4 {
        let matrix = transform.transformationMatrix(sceneProps)
        return matrix
    }

    func zoom(delta: Float) {}
    func rotate(delta: simd_float2) {}
}

class EGArcballCamera: EGCamera {
    var minDistance: Float = 0.5
    var maxDistance: Float = 10

    var distance: Float = 0 {
        didSet { updateViewMatrix() }
    }

    var rotation: simd_float3 = [0, 0, 0] {
        didSet { updateViewMatrix() }
    }

    var target: simd_float3 = [0, 0, 0] {
        didSet { updateViewMatrix() }
    }

    var viewMatrix = matrix_identity_float4x4

    override init() {
        super.init()
        updateViewMatrix()
    }

    init(distance: Float, target: simd_float3) {
        self.distance = distance
        self.target = target
        super.init()
        updateViewMatrix()
    }

    func updateViewMatrix() {
        let translateMatrix = EGMatrixBuilder.createTranslationMatrix(x: target.x, y: target.y, z: target.z - distance)
        let rotateMatrix = EGMatrixBuilder.createRotationMatrix(x: rotation.x, y: -rotation.y, z: 0)
        let matrix = translateMatrix * rotateMatrix
        position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        print("position: \(position)")
        viewMatrix = matrix
    }

    override func viewMatrix(sceneProps: EGSceneProps) -> matrix_float4x4 {
        return viewMatrix
    }

    override func zoom(delta: Float) {
        let sensitivity: Float = 3
        distance -= delta * sensitivity
        updateViewMatrix()
    }

    override func rotate(delta: simd_float2) {
        let sensitivity: Float = 0.005
        rotation.y += delta.x * sensitivity
        rotation.x += delta.y * sensitivity
        rotation.x = max(-Float.pi/2,
                         min(rotation.x,
                             Float.pi/2))
        updateViewMatrix()
    }
}
