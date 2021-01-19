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
            EGLight.directional(color: [1, 1, 1], position: [0, 0, 1], intensity: 0.2, specularColor: [0.6, 0.6, 0.6])
        )
        scene.lights.append(
            EGLight.directional(color: [1, 1, 1], position: [0, 0, -1], intensity: 0.2, specularColor: [0.6, 0.6, 0.6])
        )
        scene.lights.append(
            EGLight.ambient(color: [1, 1, 1], intensity: 0.4)
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
        scene.lights.append(EGLight.ambient(color: [1, 1, 1], intensity: 1))

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
            EGLight.directional(color: [1, 1, 1], position: [0, 0, 1], intensity: 1, specularColor: [0.6, 0.6, 0.6])
        )
        scene.lights.append(
            EGLight.directional(color: [1, 1, 1], position: [0, 0, -1], intensity: 0.7, specularColor: [0.6, 0.6, 0.6])
        )
        scene.lights.append(
            EGLight.directional(color: [1, 1, 1], position: [0, 1, 0], intensity: 0.3, specularColor: [0.6, 0.6, 0.6])
        )
        scene.lights.append(
            EGLight.directional(color: [1, 1, 1], position: [0, -1, 0], intensity: 0.3, specularColor: [0.6, 0.6, 0.6])
        )

        let monkey = EGMonkey()
        monkey.color.set(r: 150/255, g: 75/255, b: 0, a: 1)
        monkey.smoothIntensity = 0.5
        scene.add(monkey)

        let ring = EGRing()
        ring.transform.translate.set(x: 0, y: 1.25, z: 0)
        ring.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring.color.set(r: 212/255, g: 175/255, b: 55/255, a: 0.1)
        ring.smoothIntensity = 0.5
        scene.add(ring)

        let monkey2 = EGMonkey()
        monkey2.transform.translate.set(x: -3, y: 0, z: 0)
        monkey2.color.set(r: 150/255, g: 75/255, b: 0, a: 1)
        scene.add(monkey2)

        let ring2 = EGRing()
        ring2.transform.translate.set(x: -3, y: 1.25, z: 0)
        ring2.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring2.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring2.color.set(r: 212/255, g: 175/255, b: 55/255, a: 1)
        scene.add(ring2)

        let monkey3 = EGMonkey()
        monkey3.transform.translate.set(x: 3, y: 0, z: 0)
        monkey3.color.set(r: 150/255, g: 75/255, b: 0, a: 1)
        monkey3.smoothIntensity = 1
        scene.add(monkey3)

        let ring3 = EGRing()
        ring3.transform.translate.set(x: 3, y: 1.25, z: 0)
        ring3.transform.scale.set(x: 0.5, y: 0.25, z: 0.5)
        ring3.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        ring3.color.set(r: 212/255, g: 175/255, b: 55/255, a: 1)
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
            EGLight.directional(color: [0.6, 0.6, 0.6], position: [0, 0, 1], intensity: 0.5, specularColor: [0.1, 0.1, 0.1])
        )
        scene.lights.append(
            EGLight.directional(color: [0.6, 0.6, 0.6], position: [0, 0.5, -1], intensity: 0.5, specularColor: [0.1, 0.1, 0.1])
        )
        scene.lights.append(
            EGLight.ambient(color: [0.4, 0.4, 0.4], intensity: 1)
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
        
        return scene
    }
}
