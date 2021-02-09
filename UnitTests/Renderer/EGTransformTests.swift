//
//  EGTransformTests.swift
//  UnitTests
//
//  Created by Michael Le on 2020-11-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class EGTransformTests: XCTestCase {
    var sceneProps = EGSceneProps()
    
    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps()
    }
    
    func testEGTransformFunction() throws {
        let translate = EGTransformFunction(
            defaultValues: [1, 3, 4],
            matrixFunction: { xyz in matrix_float4x4(translation: xyz) }
        )
        
        // Default Values
        XCTAssert(translate.equations.x.evaluate(sceneProps) == 1)
        XCTAssert(translate.equations.y.evaluate(sceneProps) == 3)
        XCTAssert(translate.equations.z.evaluate(sceneProps) == 4)
        
        translate.set(x: 3, y: 3, z: 5)
        XCTAssert(translate.evaluate(sceneProps) == matrix_float4x4(translation: [3, 3, 5]))
        
        translate.set(
            x: EGBinaryOp(
                type: .add,
                leftChild: EGTime(),
                rightChild: EGConstant(4)
            ),
            y: EGUnaryOp(type: .sin, child: EGConstant(0.22)),
            z: EGConstant(10)
        )
        XCTAssert(translate.evaluate(sceneProps) == matrix_float4x4(translation: [sceneProps.time + 4, sin(0.22), 10]))
        
        translate.set(
            x: EGBinaryOp(
                type: .add,
                leftChild: EGTime(),
                rightChild: EGBinaryOp(
                    type: .mul,
                    leftChild: EGTime(),
                    rightChild: EGConstant(5)
                )
            ),
            y: EGUnaryOp(type: .sin, child: EGConstant(0.22)),
            z: EGConstant(10)
        )
        XCTAssert(
            translate.evaluate(sceneProps) == matrix_float4x4(translation: [sceneProps.time + (sceneProps.time * 5), sin(0.22), 10])
        )
    }
    
    func testEGTransformProperty() throws {
        let transform = EGTransformProperty()
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        
        transform.translate.set(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(8))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(311)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        var transformationMatrix = transform.transformationMatrix(sceneProps)
        var expectedMatrix = matrix_float4x4(translation: [cos(sin(12)), cos(tan(8)), abs(sin(311))])
        print("got: \(transformationMatrix)\n\nwant: \(expectedMatrix)")
        XCTAssert(transformationMatrix == expectedMatrix)
        
        transform.translate.set(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(1.12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(88))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(3)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
        XCTAssert(transformationMatrix == expectedMatrix)
    
        transform.rotate.set(x: 1, y: 2, z: 3)
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
        transformationMatrix = transform.transformationMatrix(sceneProps)
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 122
        transform.scale.set(
            x: EGUnaryOp(type: .sin, child: EGTime()),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGTime())),
            z: EGUnaryOp(type: .sin, child: EGTime())
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == false)
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
            * matrix_float4x4(scale: [sin(sceneProps.time), cos(cos(sceneProps.time)), sin(sceneProps.time)])
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 15885
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
            * matrix_float4x4(scale: [sin(sceneProps.time), cos(cos(sceneProps.time)), sin(sceneProps.time)])
        XCTAssert(transformationMatrix == expectedMatrix)
    }
}
