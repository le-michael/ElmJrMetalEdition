//
//  EGDemoScenes.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGDemoScenes {
    static func spinningFan() -> EGScene {
        let scene = EGScene()
        let camera = EGCamera()
        camera.transform.translate.set(x: 0, y: 0, z: -100)
        scene.camera = camera

        let numBlades = 8
        let rotationChange = (2 * Float.pi)/Float(numBlades)

        for i in 0 ..< numBlades {
            let rotationBuffer = rotationChange * Float(i)
            let blade = EGCurvedPolygon(
                p0: EGPoint2D(x: 0, y: 0),
                p1: EGPoint2D(x: 10, y: 10),
                p2: EGPoint2D(x: 20, y: 10),
                p3: EGPoint2D(x: 30, y: 0)
            )
            blade.transform.rotate.set(
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
            blade.transform.translate.set(
                x: EGBinaryOp(
                    type: .mul,
                    leftChild: EGConstant(30),
                    rightChild: EGUnaryOp(
                        type: .cos,
                        child: EGTime()
                    )
                ),
                y: EGConstant(0),
                z: EGConstant(0)
            )
            blade.color.set(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
                b: EGConstant(1),
                a: EGConstant(1)
            )

            scene.add(blade)
        }

        let circle = EGRegularPolygon(30)
        circle.transform.scale.set(x: 5, y: 5, z: 1)
        circle.transform.translate.set(
            x: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(30),
                rightChild: EGUnaryOp(
                    type: .cos,
                    child: EGTime()
                )
            ),
            y: EGConstant(0),
            z: EGConstant(0)
        )
        circle.color.set(
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
        camera.transform.translate.set(x: 0, y: 0, z: -150)
        scene.camera = camera

        func fratcalTreeHelper(currentDepth: Float, rotation: Float, currentPos: simd_float3, length: Float) {
            if length < 1 { return }

            let theta = 30 * Float.pi/180
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
                line.color.set(
                    r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())),
                    g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())),
                    b: EGConstant(1),
                    a: EGConstant(1)
                )
            }
            scene.add(line)
        }

        fratcalTreeHelper(currentDepth: 0, rotation: Float.pi/2, currentPos: simd_float3(0, -60, 0), length: 20)

        return scene
    }

    static func pointField() -> EGScene {
        let scene = EGScene()
        let camera = EGCamera()
        camera.transform.translate.set(x: 0, y: 0, z: -125)
        camera.transform.rotate.set(
            x: EGConstant(20 * Float.pi/180),
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
                point.transform.translate.set(
                    x: EGConstant(Float(j) * Float(spacing) - (Float(rows * spacing)/2)),
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
                    z: EGConstant(Float(i) * Float(spacing) - (Float(cols * spacing)/2))
                )
                point.transform.scale.set(x: 0.5, y: 0.5, z: 1)
                point.color.set(
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
        scene.camera.transform.translate.set(x: 0, y: 0, z: -40)
        scene.camera.transform.rotate.set(
            x: EGConstant(0),
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

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                position: (EGConstant(0), EGConstant(0), EGConstant(1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6))
            )
        )
        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                position: (EGConstant(0), EGConstant(0), EGConstant(-1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6))
            )
        )
        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                intensity: EGConstant(0.4)
            )
        )

        var pointCords: [simd_float3] = []

        let layers = 25
        let pointSpacing = 2
        let layerSpacing = 2

        for i in 0 ..< layers {
            pointCords.append(simd_float3(Float(pointSpacing), Float(pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing)/2))
            pointCords.append(simd_float3(Float(pointSpacing), Float(-pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing)/2))
            pointCords.append(simd_float3(Float(-pointSpacing), Float(-pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing)/2))
            pointCords.append(simd_float3(Float(-pointSpacing), Float(pointSpacing), Float(i * layerSpacing) - Float(layers * layerSpacing)/2))
        }
        for pointCord in pointCords {
            let point = EGModel(modelName: "cube.obj")
            point.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
            point.transform.translate.set(x: pointCord.x, y: pointCord.y, z: pointCord.z)
            point.color.set(
                r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGBinaryOp(type: .add, leftChild: EGConstant(pointCord.z), rightChild: EGTime()))),
                b: EGConstant(1),
                a: EGConstant(1)
            )
            point.transform.rotate.set(x: EGTime(), y: EGTime(), z: EGConstant(0))
            scene.add(point)
        }

        let ball = EGModel(modelName: "cube.obj")
        ball.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        ball.transform.translate.set(
            x: EGConstant(0),
            y: EGConstant(0),
            z: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(Float(layers * layerSpacing)/2),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        ball.color.set(r: 1, g: 0, b: 0, a: 1)
        scene.add(ball)

        return scene
    }

    static func rings3D() -> EGScene {
        let scene = EGScene()
        let camera = EGCamera()
        camera.transform.translate.set(x: 0, y: 0, z: -100)
        camera.transform.rotate.set(
            x: EGConstant(0),
            y: EGTime(),
            z: EGTime()
        )
        scene.camera = camera
        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                intensity: EGConstant(1)
            )
        )

        for i in 0 ..< 14 {
            let count = i * 10 + 30
            for j in 0 ..< count {
                let amplitude = Float(i * 4)
                let step = Float(j)/60 * 10
                let asteroid = EGSphere()
                asteroid.transform.scale.set(x: 1, y: 1, z: 1)
                asteroid.transform.translate.set(
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
                asteroid.color.set(
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

    static func monkeys() -> EGScene {
        let scene = EGScene()
        scene.camera.transform.translate.set(x: 0, y: 0, z: -5)
        scene.camera.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        let camera = EGArcballCamera(distance: 2, target: [0, 0, 0])
        scene.camera = camera

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0), EGConstant(1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.2), EGConstant(0.2), EGConstant(0.2))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0), EGConstant(-1)),
                intensity: EGConstant(0.7),
                specularColor: (EGConstant(0.2), EGConstant(0.2), EGConstant(0.2))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(1), EGConstant(0)),
                intensity: EGConstant(0.3),
                specularColor: (EGConstant(0.2), EGConstant(0.2), EGConstant(0.2))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(-1), EGConstant(0)),
                intensity: EGConstant(0.3),
                specularColor: (EGConstant(0.2), EGConstant(0.2), EGConstant(0.2))
            )
        )

        let monkey = EGMonkey()
        monkey.shininess = 32
        monkey.submeshColorMap[0] = EGColorProperty(r: 150/255, g: 75/255, b: 0, a: 1)
        monkey.smoothIntensity = 0.5
        scene.add(monkey)

        let ring = EGRing()
        ring.shininess = 32
        ring.transform.translate.set(x: 0, y: 1.25, z: 0)
        ring.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring.submeshColorMap[0] = EGColorProperty(r: 212/255, g: 175/255, b: 55/255, a: 0.1)
        ring.smoothIntensity = 0.5
        scene.add(ring)

        let monkey2 = EGMonkey()
        monkey2.shininess = 32
        monkey2.transform.translate.set(x: -3, y: 0, z: 0)
        monkey2.submeshColorMap[0] = EGColorProperty(r: 150/255, g: 75/255, b: 0, a: 1)
        scene.add(monkey2)

        let ring2 = EGRing()
        ring.shininess = 32
        ring2.transform.translate.set(x: -3, y: 1.25, z: 0)
        ring2.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring2.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring2.submeshColorMap[0] = EGColorProperty(r: 212/255, g: 175/255, b: 55/255, a: 0.1)
        scene.add(ring2)

        let monkey3 = EGMonkey()
        monkey3.shininess = 32
        monkey3.transform.translate.set(x: 3, y: 0, z: 0)
        monkey3.submeshColorMap[0] = EGColorProperty(r: 150/255, g: 75/255, b: 0, a: 1)
        monkey3.smoothIntensity = 1
        scene.add(monkey3)

        let ring3 = EGRing()
        ring3.shininess = 32
        ring3.transform.translate.set(x: 3, y: 1.25, z: 0)
        ring3.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring3.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring3.submeshColorMap[0] = EGColorProperty(r: 212/255, g: 175/255, b: 55/255, a: 0.1)
        ring3.smoothIntensity = 1
        scene.add(ring3)

        return scene
    }

    static func campSite() -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 5, target: [0, -1, 0])
        camera.rotation = [Float(-35).degreesToRadians, 0, 0]
        scene.camera = camera
        scene.viewClearColor = MTLClearColorMake(0.529, 0.808, 0.922, 1.0)

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0), EGConstant(1)),
                intensity: EGConstant(0.5),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0.5), EGConstant(-1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.3), EGConstant(0.3), EGConstant(0.3)),
                position: (EGConstant(0), EGConstant(-0.5), EGConstant(-1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )

        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(0.4), EGConstant(0.4), EGConstant(0.4)),
                intensity: EGConstant(0.5)
            )
        )

        scene.lights.append(
            EGPointLight(
                color: (EGConstant(0), EGConstant(0.3), EGConstant(1)),
                position: (EGBinaryOp(type: .mul, leftChild: EGConstant(0.25), rightChild: EGUnaryOp(type: .sin, child: EGTime())), EGConstant(1.2), EGUnaryOp(type: .cos, child: EGTime())),
                attenuation: (EGConstant(1), EGConstant(1), EGConstant(0))
            )
        )

        scene.lights.append(
            EGSpotLight(
                color: (EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGTime())), EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: EGTime())), EGConstant(1)),
                position: (EGConstant(0.25), EGConstant(1), EGConstant(3)),
                attenuation: (EGConstant(1), EGConstant(0), EGConstant(0)),
                coneAngle: EGConstant(Float(45).degreesToRadians),
                coneDirection: (EGConstant(0), EGConstant(-0.25), EGConstant(-1)),
                coneAttenuation: EGConstant(12)
            )
        )

        let tree = EGModel(modelName: "tree_default.obj")
        tree.transform.translate.set(x: -0.75, y: 1, z: -0.25)
        scene.add(tree)

        let tent = EGModel(modelName: "tent_detailedOpen.obj")
        tent.transform.translate.set(x: -0.15, y: 1, z: 0)
        scene.add(tent)

        let logStack = EGModel(modelName: "log_stack.obj")
        logStack.transform.translate.set(x: 0.45, y: 1, z: -0.5)
        logStack.transform.rotate.set(x: 0, y: Float(45).degreesToRadians, z: 0)
        scene.add(logStack)

        let redFlower = EGModel(modelName: "flower_purpleC.obj")
        redFlower.transform.translate.set(x: 0.35, y: 1, z: 0.5)
        scene.add(redFlower)

        let purpleFlower = EGModel(modelName: "flower_purpleC.obj")
        purpleFlower.transform.translate.set(x: 0.65, y: 1, z: 0.5)
        scene.add(purpleFlower)

        let yellowlower = EGModel(modelName: "flower_purpleC.obj")
        yellowlower.transform.translate.set(x: 0.55, y: 1, z: 0.6)
        scene.add(yellowlower)

        let campFireStones = EGModel(modelName: "campfire_stones.obj")
        campFireStones.transform.translate.set(x: -0.25, y: 1, z: 0.65)
        campFireStones.transform.scale.set(x: 0.75, y: 0.75, z: 0.75)
        scene.add(campFireStones)

        let campFireLogs = EGModel(modelName: "campfire_logs.obj")
        campFireLogs.transform.translate.set(x: -0.25, y: 1, z: 0.65)
        campFireLogs.transform.scale.set(x: 0.75, y: 0.75, z: 0.75)
        scene.add(campFireLogs)

        let cliffBlock1 = EGModel(modelName: "cliff_block_rock.obj")
        cliffBlock1.transform.translate.set(x: -0.5, y: 0, z: -0.5)
        scene.add(cliffBlock1)

        let cliffBlock2 = EGModel(modelName: "cliff_block_rock.obj")
        cliffBlock2.transform.translate.set(x: -0.5, y: 0, z: 0.5)
        scene.add(cliffBlock2)

        let cliffBlock3 = EGModel(modelName: "cliff_block_rock.obj")
        cliffBlock3.transform.translate.set(x: 0.5, y: 0, z: -0.5)
        scene.add(cliffBlock3)

        let cliffBlock4 = EGModel(modelName: "cliff_block_rock.obj")
        cliffBlock4.transform.translate.set(x: 0.5, y: 0, z: 0.5)
        scene.add(cliffBlock4)

        let astronaut = EGModel(modelName: "astronautA.obj")
        astronaut.transform.translate.set(x: 0.5, y: 1, z: 0.5)
        astronaut.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        scene.add(astronaut)

        return scene
    }

    static func snowman() -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 5, target: [0, -1, 0])
        camera.rotation = [Float(-35).degreesToRadians, 0, 0]
        scene.camera = camera
        scene.viewClearColor = MTLClearColorMake(0.529, 0.808, 0.922, 1.0)

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(1), EGConstant(2), EGConstant(2)),
                intensity: EGConstant(0),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )
        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                intensity: EGConstant(0.5)
            )
        )

        let top = EGSphere()
        top.smoothIntensity = 0.5
        top.transform.translate.set(x: 0, y: 2.25, z: 0)
        top.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        scene.add(top)

        let middle = EGSphere()
        middle.smoothIntensity = 0.5
        middle.transform.translate.set(x: 0, y: 1.25, z: 0)
        middle.transform.scale.set(x: 0.75, y: 0.75, z: 0.75)
        scene.add(middle)

        let bottom = EGSphere()
        bottom.smoothIntensity = 0.5
        bottom.transform.scale.set(x: 1, y: 1, z: 1)
        scene.add(bottom)

        let eyeLeft = EGSphere()
        eyeLeft.transform.scale.set(x: 0.075, y: 0.075, z: 0.075)
        eyeLeft.transform.translate.set(x: -0.30, y: 2.25, z: 0.45)
        eyeLeft.submeshColorMap[0] = EGColorProperty(r: 0, g: 0, b: 0, a: 1)
        scene.add(eyeLeft)

        let eyeRight = EGSphere()
        eyeRight.transform.scale.set(x: 0.075, y: 0.075, z: 0.075)
        eyeRight.transform.translate.set(x: 0.30, y: 2.25, z: 0.45)
        eyeRight.submeshColorMap[0] = EGColorProperty(r: 0, g: 0, b: 0, a: 1)
        scene.add(eyeRight)

        let nose = EGCapsule()
        nose.transform.rotate.set(x: Float(90).degreesToRadians, y: 0, z: 0)
        nose.transform.scale.set(x: 0.1, y: 0.1, z: 0.1)
        nose.transform.translate.set(x: 0, y: 2.15, z: 0.5)
        nose.smoothIntensity = 1
        nose.submeshColorMap[0] = EGColorProperty(r: 252/255, g: 174/255, b: 101/255, a: 1)
        scene.add(nose)

        let hat = EGGroup()
        hat.transform.translate.set(x: 0.2, y: 2.75, z: 0)
        hat.transform.rotate.set(x: EGConstant(0), y: EGConstant(0), z: EGTime())
        hat.transform.scale.set(x: 0.75, y: 0.75, z: 0.75)
        scene.add(hat)

        let hatRim = EGCylinder()
        hatRim.transform.scale.set(x: 0.35, y: 0.02, z: 0.35)
        hatRim.transform.translate.set(x: 0, y: -0.1, z: 0)
        hatRim.smoothIntensity = 0.5
        hatRim.submeshColorMap[0] = EGColorProperty(r: 0.1, g: 0.1, b: 0.1, a: 1)
        hat.add(hatRim)

        let hatTop = EGCylinder()
        hatTop.transform.scale.set(x: 0.25, y: 0.2, z: 0.25)
        hatTop.transform.translate.set(x: 0, y: 0.1, z: 0)
        hatTop.smoothIntensity = 0.5
        hatTop.submeshColorMap[0] = EGColorProperty(r: 0.1, g: 0.1, b: 0.1, a: 1)
        hat.add(hatTop)

        let wave = EGBinaryOp(
            type: .add,
            leftChild: EGConstant(Float(45).radiansToDegrees - Float(15).radiansToDegrees),
            rightChild: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(Float(15).degreesToRadians),
                rightChild: EGUnaryOp(
                    type: .sin,
                    child: EGBinaryOp(
                        type: .mul,
                        leftChild: EGTime(),
                        rightChild: EGConstant(8)
                    )
                )
            )
        )

        let leftArm = EGCylinder()
        leftArm.transform.scale.set(x: 0.05, y: 0.8, z: 0.05)
        leftArm.transform.translate.set(x: -0.55, y: 1.65, z: 0)
        leftArm.transform.rotate.set(x: EGConstant(0), y: EGConstant(0), z: wave)
        leftArm.submeshColorMap[0] = EGColorProperty(r: 150/255, g: 75/255, b: 0, a: 1)
        scene.add(leftArm)

        let rightArm = EGCylinder()
        rightArm.transform.scale.set(x: 0.05, y: 0.8, z: 0.05)
        rightArm.transform.translate.set(x: 0.67, y: 1.30, z: 0)
        rightArm.transform.rotate.set(x: 0, y: 0, z: Float(35).degreesToRadians)
        rightArm.submeshColorMap[0] = EGColorProperty(r: 150/255, g: 75/255, b: 0, a: 1)
        scene.add(rightArm)

        return scene
    }

    static func spacebase() -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 15, target: [0, -1, 0])
        camera.rotation = [Float(-35).degreesToRadians, 0, 0]
        scene.camera = camera
        scene.viewClearColor = MTLClearColorMake(255/255, 218/255, 199/255, 1.0)
        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0), EGConstant(1)),
                intensity: EGConstant(0.5),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(0), EGConstant(0.5), EGConstant(-1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )

        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.3), EGConstant(0.3), EGConstant(0.3)),
                position: (EGConstant(0), EGConstant(-0.5), EGConstant(-1)),
                intensity: EGConstant(0.2),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )
        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(0.9), EGConstant(0.9), EGConstant(0.9)),
                intensity: EGConstant(0.5)
            )
        )

        for i in 0...12 {
            for j in 0...12 {
                let terrain = EGModel(modelName: "terrain.obj")
                terrain.transform.translate.set(x: -6 + Float(i), y: 0, z: -6 + Float(j))
                scene.add(terrain)
            }
        }

        let ships = ["craft_speederA.obj", "craft_speederB.obj", "craft_speederC.obj", "craft_speederD.obj"]
        for i in 0...3 {
            for j in 0...14 {
                let height = Float(3) + Float(i)
                let delay = (2 * Float.pi)/15 * Float(j) + Float.pi/10 * Float(i)
                let timeShift = EGBinaryOp(type: .add, leftChild: EGConstant(delay), rightChild: EGTime())
                let ship = EGModel(modelName: ships[i])
                let color = EGColorProperty()
                color.set(
                    r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: timeShift)),
                    g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: timeShift)),
                    b: EGConstant(1),
                    a: EGConstant(1)
                )

                ship.transform.scale.set(x: 0.25, y: 0.25, z: 0.25)
                ship.transform.translate.set(
                    x: EGBinaryOp(type: .mul, leftChild: EGBinaryOp(type: .add, leftChild: EGConstant(4), rightChild: EGUnaryOp(type: .sin, child: EGTime())), rightChild: EGUnaryOp(type: .sin, child: timeShift)),
                    y: EGConstant(height),
                    z: EGBinaryOp(type: .mul, leftChild: EGBinaryOp(type: .add, leftChild: EGConstant(4), rightChild: EGUnaryOp(type: .sin, child: EGTime())), rightChild: EGUnaryOp(type: .cos, child: timeShift))
                )
                ship.transform.rotate.set(
                    x: EGConstant(0),
                    y: EGBinaryOp(type: .add, leftChild: EGConstant(Float(90).degreesToRadians), rightChild: timeShift),
                    z: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .neg, child: timeShift))
                )

                scene.add(ship)
            }
        }

        let rock1 = EGModel(modelName: "rocks_smallA.obj")
        rock1.transform.translate.set(x: -0.5, y: 0, z: 1)
        scene.add(rock1)

        let rock2 = EGModel(modelName: "rocks_smallB.obj")
        rock2.transform.translate.set(x: 3, y: 0, z: 0.75)
        scene.add(rock2)

        let hanger1 = EGModel(modelName: "hangar_largeB.obj")
        hanger1.transform.translate.set(x: -4, y: 0, z: -3)
        hanger1.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        scene.add(hanger1)

        let hanger2 = EGModel(modelName: "hangar_largeB.obj")
        hanger2.transform.translate.set(x: -2.5, y: 0, z: -3)
        hanger2.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        scene.add(hanger2)

        let rocket = EGGroup()
        rocket.transform.scale.set(x: 0.5, y: 0.5, z: 0.5)
        rocket.transform.translate.set(x: 3, y: 0, z: -3)
        scene.add(rocket)

        let rocketBase = EGModel(modelName: "rocket_baseB.obj")
        rocket.add(rocketBase)

        let rocketFuel = EGModel(modelName: "rocket_fuelB.obj")
        rocketFuel.transform.translate.set(x: 0, y: 1, z: 0)
        rocket.add(rocketFuel)

        let rocketSides = EGModel(modelName: "rocket_sidesA.obj")
        rocketSides.transform.translate.set(x: 0, y: 2, z: 0)
        rocket.add(rocketSides)

        let rocketFins = EGModel(modelName: "rocket_finsB.obj")
        rocketFins.transform.translate.set(x: 0, y: 3, z: 0)
        rocket.add(rocketFins)

        let rocketTop = EGModel(modelName: "rocket_topB.obj")
        rocketTop.transform.translate.set(x: 0, y: 3.5, z: 0)
        rocket.add(rocketTop)

        // Create roads
        for i in 0...8 {
            let road = EGModel(modelName: "terrain_roadStraight.obj")
            road.transform.rotate.set(x: 0, y: Float.pi/2, z: 0)
            road.transform.translate.set(x: -4 + Float(i), y: 0.01, z: -1)
            scene.add(road)
        }

        for i in 0...1 {
            for j in 0...1 {
                let satelite = EGModel(modelName: "satelliteDish_detailed.obj")
                satelite.transform.translate.set(x: -4 + Float(j), y: 0, z: 1 + Float(i))
                scene.add(satelite)
            }
        }

        let crater1 = EGModel(modelName: "crater.obj")
        crater1.transform.translate.set(x: -3.75, y: 0, z: 4)

        scene.add(crater1)

        let crater2 = EGModel(modelName: "craterLarge.obj")
        crater2.transform.translate.set(x: 1.42, y: 0, z: 2.3)
        scene.add(crater2)

        let halfTime = EGBinaryOp(type: .div, leftChild: EGTime(), rightChild: EGConstant(2))
        let thirdTime = EGBinaryOp(type: .div, leftChild: EGTime(), rightChild: EGConstant(3))

        let crystalColor = EGColorProperty()
        crystalColor.set(
            r: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: halfTime)),
            g: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .cos, child: thirdTime)),
            b: EGConstant(1),
            a: EGConstant(1)
        )

        let crystal1 = EGModel(modelName: "rock_crystalsLargeA.obj")
        crystal1.transform.translate.set(x: 0, y: 0, z: -3)
        crystal1.transform.scale.set(x: 2, y: 2, z: 2)
        crystal1.submeshColorMap[2] = crystalColor
        scene.add(crystal1)

        let crystal2 = EGModel(modelName: "rock_crystalsLargeB.obj")
        crystal2.transform.translate.set(x: -1.4, y: 0, z: 3.21)
        crystal2.transform.scale.set(x: 2, y: 2, z: 2)
        crystal2.submeshColorMap[2] = crystalColor
        scene.add(crystal2)

        let crystal3 = EGModel(modelName: "rock_crystalsLargeB.obj")
        crystal3.transform.translate.set(x: 3.4, y: 0, z: 3.75)
        crystal3.transform.scale.set(x: 3, y: 3, z: 3)
        crystal3.submeshColorMap[2] = crystalColor
        scene.add(crystal3)

        return scene
    }
}
