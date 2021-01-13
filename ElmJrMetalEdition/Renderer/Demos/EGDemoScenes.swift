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
        let camera = EGCamera()
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -100)
        scene.camera = camera

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
            blade.transform.rotate.setRotation(
                x: EGConstant(0),
                y: EGConstant(0),
                z: EGBinaryOp(
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
            blade.transform.translate.xEquation = EGBinaryOp(
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
        circle.transform.scale.setScale(x: 5, y: 5, z: 1)
        circle.transform.translate.xEquation = EGBinaryOp(
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
        let camera = EGCamera()
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -150)
        scene.camera = camera

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
        let camera = EGCamera()
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -125)
        camera.transform.rotate.setRotation(
            x: EGConstant(-20 * Float.pi / 180),
            y: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(0.5),
                rightChild: EGUnaryOp(
                    type: .sin,
                    child: EGTime()
                )
            ),
            z: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(0.5),
                rightChild: EGUnaryOp(
                    type: .cos,
                    child: EGTime()
                )
            )
        )
        scene.camera = camera

        let rows = 30
        let cols = 30
        let spacing = 5

        for i in 0 ..< rows {
            for j in 0 ..< cols {
                let point = EGRegularPolygon(30)
                point.transform.translate.setTranslation(
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
                point.transform.scale.setScale(x: 0.5, y: 0.5, z: 1)
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
        let camera = EGCamera()
        scene.camera = camera
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -50)
        camera.transform.rotate.setRotation(
            x: EGConstant(-20 * Float.pi / 180),
            y: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(0.5),
                rightChild: EGUnaryOp(
                    type: .sin,
                    child: EGTime()
                )
            ),
            z: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(0.5),
                rightChild: EGUnaryOp(
                    type: .cos,
                    child: EGTime()
                )
            )
        )

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
            let point = EGCube(extent: [1, 1, 1])
            point.transform.translate.setTranslation(x: pointCord.x, y: pointCord.y, z: pointCord.z)
            point.color.setColor(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                b: EGConstant(1),
                a: EGConstant(1)
            )
            point.transform.rotate.setRotation(x: EGTime(), y: EGTime(), z: EGConstant(0))
            point.drawOutline = true
            scene.add(point)
        }

        let ball = EGSphere(extent: [0.75, 0.75, 0.75], segments: [25, 25])
        ball.transform.translate.setTranslation(
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
        let camera = EGCamera()
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -5)
        camera.transform.rotate.setRotation(x: EGTime(), y: EGConstant(0), z: EGConstant(0))
        scene.camera = camera

        let sphere = EGSphere(extent: [0.75, 0.75, 0.75], segments: [25, 25])
        sphere.color.setColor(r: 1.0, g: 0, b: 0, a: 1)
        sphere.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        sphere.transform.translate.setTranslation(x: 0, y: 2, z: 0)
        sphere.drawOutline = true
        scene.add(sphere)

        let cube = EGCube(extent: [1, 1, 1])
        cube.color.setColor(r: 0, g: 0, b: 1, a: 1)
        cube.transform.translate.setTranslation(x: -2, y: 2, z: 0)
        cube.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        cube.drawOutline = true
        scene.add(cube)

        let cone = EGCone(extent: [1, 1, 1], segments: [20, 20])
        cone.color.setColor(r: 0, g: 1, b: 0, a: 1)
        cone.transform.translate.setTranslation(x: 2, y: 2, z: 0)
        cone.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        cone.drawOutline = true
        scene.add(cone)

        let capsule = EGCapsule(extent: [0.5, 1.5, 0.5], cylinderSegments: [10, 10], hemisphereSegments: 10)
        capsule.color.setColor(r: 1, g: 1, b: 0, a: 1)
        capsule.transform.translate.setTranslation(x: 2, y: 0, z: 0)
        capsule.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        capsule.drawOutline = true
        scene.add(capsule)

        let hemisphere = EGHemisphere(extent: [0.75, 0.75, 0.75], segments: [25, 25])
        hemisphere.color.setColor(r: 1, g: 0, b: 1, a: 1)
        hemisphere.transform.translate.setTranslation(x: 0, y: 0, z: 0)
        hemisphere.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        hemisphere.drawOutline = true
        scene.add(hemisphere)

        let cylinder = EGCylinder(extent: [0.5, 1, 0.5], segments: [25, 25])
        cylinder.color.setColor(r: 0, g: 1, b: 1, a: 1)
        cylinder.transform.translate.setTranslation(x: -2, y: 0, z: 0)
        cylinder.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        cylinder.drawOutline = true
        scene.add(cylinder)

        let isosahedron = EGIcosahedron(extent: [0.75, 0.75, 0.75])
        isosahedron.color.setColor(r: 0.5, g: 0.74, b: 1, a: 1)
        isosahedron.transform.translate.setTranslation(x: -2, y: -2, z: 0)
        isosahedron.transform.rotate.setRotation(x: EGConstant(0), y: EGTime(), z: EGTime())
        isosahedron.drawOutline = true
        scene.add(isosahedron)

        return scene
    }

    static func rings3D() -> EGScene {
        let scene = EGScene()
        let camera = EGCamera()
        camera.transform.translate.setTranslation(x: 0, y: 0, z: -100)
        camera.transform.rotate.setRotation(
            x: EGConstant(0),
            y: EGTime(),
            z: EGTime()
        )
        scene.camera = camera

        for i in 0 ..< 14 {
            let count = i * 10 + 30
            for j in 0 ..< count {
                let amplitude = Float(i * 4)
                let step = Float(j) / 60 * 10
                let asteroid = EGSphere(extent: [0.75, 0.75, 0.75], segments: [25, 25])
                asteroid.transform.scale.setScale(x: 1, y: 1, z: 1)
                asteroid.transform.translate.setTranslation(
                    x: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(amplitude),
                        rightChild: EGUnaryOp(
                            type: i % 2 == 0 ? .sin : .cos,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGConstant(step),
                                rightChild: EGTime()
                            )
                        )
                    ),
                    y: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(30),
                        rightChild: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGConstant(step),
                                rightChild: EGTime()
                            )
                        )
                    ),
                    z: EGBinaryOp(
                        type: .mul,
                        leftChild: EGConstant(amplitude),
                        rightChild: EGUnaryOp(
                            type: i % 2 == 0 ? .cos : .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGConstant(step),
                                rightChild: EGTime()
                            )
                        )
                    )
                )
                asteroid.color.setColor(
                    r: EGUnaryOp(
                        type: .abs,
                        child: EGUnaryOp(
                            type: .sin,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGConstant(step),
                                rightChild: EGTime()
                            )
                        )
                    ),
                    g: EGUnaryOp(
                        type: .abs,
                        child: EGUnaryOp(
                            type: .cos,
                            child: EGBinaryOp(
                                type: .add,
                                leftChild: EGConstant(step),
                                rightChild: EGTime()
                            )
                        )
                    ),
                    b: EGConstant(1),
                    a: EGConstant(1)
                )
                scene.add(asteroid)
            }
        }

        return scene
    }

    static func cactus() -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 2, target: [0, 0, -8])
        scene.camera = camera

        // Flower Pot
        let potBottom = EGCylinder(extent: [1, 1.5, 1], segments: [10, 1])
        potBottom.transform.translate.setTranslation(x: 0, y: -2, z: 0)
        potBottom.color.setColor(r: 1, g: 0.5, b: 0, a: 1)
        potBottom.drawOutline = true
        scene.add(potBottom)

        let potTop = EGCylinder(extent: [1.25, 1, 1.25], segments: [10, 1])
        potTop.transform.translate.setTranslation(x: 0, y: -1, z: 0)
        potTop.color.setColor(r: 1, g: 0.5, b: 0, a: 1)
        potTop.drawOutline = true
        scene.add(potTop)

        let soil = EGHemisphere(extent: [1.2, 0.5, 1.2], segments: [10, 10])
        soil.transform.translate.setTranslation(x: 0, y: -0.7, z: 0)
        soil.color.setColor(r: 0.8, g: 0.5, b: 0.2, a: 1)
        scene.add(soil)

        // Cactus
        let stem = EGCapsule(extent: [0.75, 5, 0.75], cylinderSegments: [10, 10], hemisphereSegments: 5)
        stem.transform.translate.setTranslation(x: 0, y: 1, z: 0)
        stem.color.setColor(r: 0, g: 0.5, b: 0, a: 1)
        stem.drawOutline = true
        scene.add(stem)

        // Arm
        let arm1 = EGCapsule(extent: [0.40, 1.5, 0.40], cylinderSegments: [10, 10], hemisphereSegments: 5)
        arm1.transform.translate.setTranslation(x: 1.2, y: 1.5, z: 0)
        arm1.transform.rotate.setRotation(x: 0, y: 0, z: 1.5708)
        arm1.color.setColor(r: 0, g: 0.5, b: 0, a: 1)
        arm1.drawOutline = true
        scene.add(arm1)

        let arm2 = EGCapsule(extent: [0.40, 2, 0.40], cylinderSegments: [10, 10], hemisphereSegments: 5)
        arm2.transform.translate.setTranslation(x: 1.6, y: 2.25, z: 0)
        arm2.color.setColor(r: 0, g: 0.5, b: 0, a: 1)
        arm2.drawOutline = true
        scene.add(arm2)

        let arm3 = EGCapsule(extent: [0.40, 1.5, 0.40], cylinderSegments: [10, 10], hemisphereSegments: 5)
        arm3.transform.translate.setTranslation(x: -1.2, y: 1.5, z: 0)
        arm3.transform.rotate.setRotation(x: 0, y: 0, z: 1.5708)
        arm3.color.setColor(r: 0, g: 0.5, b: 0, a: 1)
        arm3.drawOutline = true
        scene.add(arm3)

        let arm4 = EGCapsule(extent: [0.40, 2, 0.40], cylinderSegments: [10, 10], hemisphereSegments: 5)
        arm4.transform.translate.setTranslation(x: -1.6, y: 0.75, z: 0)
        arm4.color.setColor(r: 0, g: 0.5, b: 0, a: 1)
        arm4.drawOutline = true
        scene.add(arm4)

        return scene
    }
    
    static func sphere() -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 2, target: [0, 0, -2])
        scene.camera = camera
        
        let sphere = EGSphere(extent: [1, 1, 1], segments: [20, 20])
        sphere.transform.rotate.setRotation(x: EGConstant(0), y: EGConstant(0), z: EGTime())
        sphere.transform.scale.setScale(x: 1, y: 1, z: 1)
        sphere.drawOutline = true
        scene.add(sphere)
        
        return scene
    }
}
