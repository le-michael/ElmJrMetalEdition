//
//  EGDemoScenes.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import simd

class EGDemoScenes {
    static func spinningFan() -> EGScene {
        let scene = EGScene()
        scene.camera.translationMatrix.setTranslation(x: 0, y: 0, z: -100)

        let numBlades = 8
        let rotationChange = (2 * Float.pi) / Float(numBlades)

        for i in 0 ..< numBlades {
            let rotationBuffer = rotationChange * Float(i)
            let blade = EGCurvedPolygon(
                p0: EGPoint2D(x: 0, y: 0),
                p1: EGPoint2D(x: 10, y: 10),
                p2: EGPoint2D(x: 20, y: 10),
                p3: EGPoint2D(x: 30, y: 0)
            )

            blade.transform.zRotationMatrix.setZRotation(
                angle: EGBinaryOp(
                    type: .add,
                    leftChild: EGConstant(rotationBuffer),
                    rightChild: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(0.5),
                        rightChild: EGTime()
                    )
                )
            )

            blade.p3.xEquation = EGBinaryOp(
                type: .add,
                leftChild: EGConstant(30),
                rightChild: EGBinaryOp(
                    type: .mul, leftChild: EGConstant(20),
                    rightChild: EGUnaryOp(
                        type: i % 2 == 0 ? .cos : .sin,
                        child: EGTime()
                    )
                )
            )

            blade.transform.translationMatrix.xEquation = EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(30),
                rightChild: EGUnaryOp(
                    type: .cos,
                    child: EGTime()
                )
            )
            blade.color.setColor(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
                b: EGConstant(1),
                a: EGConstant(1)
            )
            scene.add(blade)
        }

        let circle = EGRegularPolygon(30)
        circle.transform.scaleMatrix.setScale(x: 5, y: 5, z: 1)
        circle.transform.translationMatrix.xEquation = EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(30),
            rightChild: EGUnaryOp(
                type: .cos,
                child: EGTime()
            )
        )
        circle.color.setColor(
            r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
            g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
            b: EGConstant(1),
            a: EGConstant(1)
        )
        scene.add(circle)

        return scene
    }

    static func fractalTree() -> EGScene {
        let scene = EGScene()
        scene.camera.translationMatrix.setTranslation(x: 0, y: 0, z: -150)

        func fratcalTreeHelper(currentDepth: Float, rotation: Float, currentPos: simd_float3, length: Float) {
            if length < 1 { return }

            let theta = 30 * Float.pi / 180
            let nextPoint = simd_float3(currentPos.x + (length * cos(rotation)), currentPos.y + (length * sin(rotation)), 0)
            let line = EGLine2D(
                p0: currentPos,
                p1: nextPoint,
                size: max(0.2, 1 - (currentDepth * 0.45))
            )
            fratcalTreeHelper(
                currentDepth: currentDepth + 1,
                rotation: rotation + theta,
                currentPos: nextPoint,
                length: length - 1.5
            )
            fratcalTreeHelper(
                currentDepth: currentDepth + 1,
                rotation: rotation - theta,
                currentPos: nextPoint,
                length: length - 1.5
            )
            if currentDepth > 8 {
                line.color.rEquation = EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime()))
                line.color.gEquation = EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime()))
            }
            scene.add(line)
        }

        fratcalTreeHelper(currentDepth: 0, rotation: Float.pi / 2, currentPos: simd_float3(0, -60, 0), length: 20)

        return scene
    }

    static func pointField() -> EGScene {
        let scene = EGScene()
        scene.camera.translationMatrix.setTranslation(x: 0, y: 0, z: -125)
        scene.camera.xRotationMatrix.setXRotation(angle: -20 * Float.pi / 180)
        scene.camera.yRotationMatrix.setYRotation(angle: EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(0.5),
            rightChild: EGUnaryOp(
                type: .sin,
                child: EGTime()
            )
        ))
        scene.camera.zRotationMatrix.setZRotation(angle: EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(0.5),
            rightChild: EGUnaryOp(
                type: .cos,
                child: EGTime()
            )
        ))

        let rows = 30
        let cols = 30
        let spacing = 5

        for i in 0 ..< rows {
            for j in 0 ..< cols {
                let point = EGRegularPolygon(30)
                point.transform.translationMatrix.setTranslation(
                    x: EGConstant(Float(j) * Float(spacing) - (Float(rows * spacing) / 2)),
                    y: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(3),
                        rightChild: EGUnaryOp(
                            type: .neg,
                            child: EGUnaryOp(
                                type: .cos,
                                child: EGBinaryOp(
                                    type: .add,
                                    leftChild: EGBinaryOp(type: .mul, leftChild: EGConstant(4), rightChild: EGTime()),
                                    rightChild: EGConstant(Float(i + j))
                                )
                            )
                        )
                    ),
                    z: EGConstant(Float(i) * Float(spacing) - (Float(cols * spacing) / 2))
                )
                point.transform.scaleMatrix.setScale(x: 0.5, y: 0.5, z: 1)
                point.color.setColor(
                    r: EGUnaryOp(
                        type: .abs,
                        child: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGTime(),
                                rightChild: EGConstant(Float(i + j))
                            )
                        )
                    ),
                    g: EGUnaryOp(
                        type: .abs,
                        child: EGUnaryOp(
                            type: .cos,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGTime(),
                                rightChild: EGConstant(Float(i + j))
                            )
                        )
                    ),
                    b: EGConstant(1),
                    a: EGConstant(1)
                )
                scene.add(point)
            }
        }

        return scene
    }

    static func cubeTunnel() -> EGScene {
        let scene = EGScene()
        scene.camera.translationMatrix.setTranslation(x: 0, y: 0, z: -50)
        scene.camera.xRotationMatrix.setXRotation(angle: -20 * Float.pi / 180)
        scene.camera.yRotationMatrix.setYRotation(angle: EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(Float.pi),
            rightChild: EGUnaryOp(
                type: .sin,
                child: EGBinaryOp(type: .div, leftChild: EGTime(), rightChild: EGConstant(5))
            )
        ))
        scene.camera.zRotationMatrix.setZRotation(angle: EGBinaryOp(
            type: .mul,
            leftChild: EGConstant(0.5),
            rightChild: EGUnaryOp(
                type: .cos,
                child: EGTime()
            )
        ))

        var pointCords: [simd_float3] = []

        let layers = 50
        let pointSpacing = 2
        let layerSpacing = 2

        for i in 0 ..< layers {
            pointCords.append(simd_float3(Float(pointSpacing), Float(pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing) / 2))
            pointCords.append(simd_float3(Float(pointSpacing), Float(-pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing) / 2))
            pointCords.append(simd_float3(Float(-pointSpacing), Float(-pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing) / 2))
            pointCords.append(simd_float3(Float(-pointSpacing), Float(pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing) / 2))
        }
        for pointCord in pointCords {
            let point = EGCube()
            point.transform.translationMatrix.setTranslation(x: pointCord.x, y: pointCord.y, z: pointCord.z)
            point.color.setColor(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                b: EGConstant(1),
                a: EGConstant(1)
            )
            point.transform.xRotationMatrix.setXRotation(angle: EGTime())
            point.transform.yRotationMatrix.setYRotation(angle: EGTime())
            
            point.drawOutline = true
            scene.add(point)
        }

        let ball = EGSphere()
        ball.transform.translationMatrix.setTranslation(
            x: EGConstant(0),
            y: EGConstant(0),
            z: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(Float(layers * layerSpacing) / 2),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        ball.color.setColor(r: 1, g: 0, b: 0, a: 1)
        scene.add(ball)

        return scene
    }
    
    static func shapes3D() -> EGScene {
        let scene = EGScene()
        scene.camera.translationMatrix.setTranslation(x: 0, y: 0, z: -5)
        
        let sphere = EGSphere()
        sphere.color.setColor(r: 1.0, g: 0, b: 0, a: 1)
        sphere.transform.yRotationMatrix.setYRotation(angle: EGTime())
        sphere.transform.translationMatrix.setTranslation(x: 0, y: 2, z: 0)
        sphere.drawOutline = true
        scene.add(sphere)
        
        let cube = EGCube()
        cube.color.setColor(r: 0, g: 0, b: 1, a: 1)
        cube.transform.translationMatrix.setTranslation(x: -2, y: 2, z: 0)
        cube.transform.yRotationMatrix.setYRotation(angle: EGTime())
        cube.drawOutline = true
        scene.add(cube)
        
        let cone = EGCone()
        cone.color.setColor(r: 0, g: 1, b: 0, a: 1)
        cone.transform.translationMatrix.setTranslation(x: 2, y: 2, z: 0)
        cone.transform.yRotationMatrix.setYRotation(angle: EGTime())
        cone.drawOutline = true
        scene.add(cone)
        
        let capsule = EGCapsule()
        capsule.color.setColor(r: 1, g: 1, b: 0, a: 1)
        capsule.transform.translationMatrix.setTranslation(x: 2, y: 0, z: 0)
        capsule.transform.yRotationMatrix.setYRotation(angle: EGTime())
        capsule.drawOutline = true
        scene.add(capsule)
        
        let hemisphere = EGHemisphere()
        hemisphere.color.setColor(r: 1, g: 0, b: 1, a: 1)
        hemisphere.transform.translationMatrix.setTranslation(x: 0, y: 0, z: 0)
        hemisphere.transform.yRotationMatrix.setYRotation(angle: EGTime())
        hemisphere.transform.xRotationMatrix.setXRotation(angle: EGTime())
        hemisphere.drawOutline = true
        scene.add(hemisphere)
        
        let cylinder = EGCylinder()
        cylinder.color.setColor(r: 0, g: 1, b: 1, a: 1)
        cylinder.transform.translationMatrix.setTranslation(x: -2, y: 0, z: 0)
        cylinder.transform.yRotationMatrix.setYRotation(angle: EGTime())
        cylinder.transform.xRotationMatrix.setXRotation(angle: EGTime())
        cylinder.drawOutline = true
        scene.add(cylinder)
        
        let isosahedron = EGIcosahedron()
        isosahedron.color.setColor(r: 0.5, g: 0.74, b: 1, a: 1)
        isosahedron.transform.translationMatrix.setTranslation(x: -2, y: -2, z: 0)
        isosahedron.transform.yRotationMatrix.setYRotation(angle: EGTime())
        isosahedron.transform.xRotationMatrix.setXRotation(angle: EGTime())
        isosahedron.drawOutline = true
        scene.add(isosahedron)
        
        return scene
    }
}
