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
    var sceneProps: EGSceneProps!
    
    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }
    
    func testEGTranslationMatrix() throws {
        let translationMatrix = EGTranslationMatrix()
        translationMatrix.setTranslation(x: 1, y: 10.2, z: 32.1)
        var expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: 1, y: 10.2, z: 32.1)
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translationMatrix.usesTime() == false)
        
        sceneProps.time = 1.22223
        translationMatrix.setTranslation(
            x: EGConstant(1.22),
            y: EGTime(),
            z: EGUnaryOp(type: .cos, child: EGTime())
        )
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(
            x: 1.22,
            y: sceneProps.time,
            z: cos(sceneProps.time)
        )
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translationMatrix.usesTime() == true)
        
        sceneProps.time = 2123.222
        translationMatrix.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGTime())),
            y: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .sin, child: EGConstant(1.22))),
            z: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGTime()))
        )
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(
            x: cos(tan(sceneProps.time)),
            y: sin(sin(1.22)),
            z: cos(cos(sceneProps.time))
        )
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translationMatrix.usesTime() == true)
    }
    
    func testEGRotationMatrix() throws {
        let rotationMatrix = EGRotationMatrix()
        rotationMatrix.setRotation(x: 1, y: 2, z: 300)
        var expectedMatrix = EGMatrixBuilder.createXRotationMatrix(radians: 1)
            * EGMatrixBuilder.createYRotationMatrix(radians: 2)
            * EGMatrixBuilder.createZRotationMatrix(radians: 300)
        XCTAssert(rotationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotationMatrix.usesTime() == false)
        
        sceneProps.time = 21.3
        rotationMatrix.setRotation(
            x: EGConstant(2),
            y: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .cos, child: EGTime())),
            z: EGBinaryOp(type: .add, leftChild: EGUnaryOp(type: .tan, child: EGTime()), rightChild: EGTime())
        )
        expectedMatrix = EGMatrixBuilder.createXRotationMatrix(radians: 2)
            * EGMatrixBuilder.createYRotationMatrix(radians: sin(cos(sceneProps.time)))
            * EGMatrixBuilder.createZRotationMatrix(radians: tan(sceneProps.time) + sceneProps.time)
        XCTAssert(rotationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotationMatrix.usesTime() == true)
        
        sceneProps.time = 2000.333
        rotationMatrix.setRotation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGBinaryOp(type: .add, leftChild: EGTime(), rightChild: EGConstant(1)))),
            y: EGBinaryOp(type: .sub, leftChild: EGTime(), rightChild: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .cos, child: EGConstant(12)))),
            z: EGConstant(232)
        )
        expectedMatrix = EGMatrixBuilder.createXRotationMatrix(radians: cos(sin(sceneProps.time + 1)))
            * EGMatrixBuilder.createYRotationMatrix(radians: sceneProps.time - sin(cos(12)))
            * EGMatrixBuilder.createZRotationMatrix(radians: 232)
        XCTAssert(rotationMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotationMatrix.usesTime() == true)
    }
    
    func testEGScaleMatrix() throws {
        let scaleMatrix = EGScaleMatrix()
        scaleMatrix.setScale(x: 1, y: 2, z: 3)
        var expectedMatrix = EGMatrixBuilder.createScaleMatrix(x: 1, y: 2, z: 3)
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scaleMatrix.usesTime() == false)
        
        sceneProps.time = 123.2222
        scaleMatrix.setScale(
            x: EGConstant(10.22),
            y: EGUnaryOp(type: .cos, child: EGTime()),
            z: EGUnaryOp(type: .sin, child: EGTime())
        )
        expectedMatrix = EGMatrixBuilder.createScaleMatrix(
            x: 10.22,
            y: cos(sceneProps.time),
            z: sin(sceneProps.time)
        )
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scaleMatrix.usesTime() == true)
    
        sceneProps.time = 111.2222
        scaleMatrix.setScale(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGTime())),
            y: EGUnaryOp(type: .tan, child: EGTime()),
            z: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .tan, child: EGConstant(2.33)))
        )
        expectedMatrix = EGMatrixBuilder.createScaleMatrix(
            x: cos(sin(sceneProps.time)),
            y: tan(sceneProps.time),
            z: sin(tan(2.33))
        )
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scaleMatrix.usesTime() == true)
    }
    
    func testEGTransformProperty() throws {
        let transform = EGTransformProperty()
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        
        transform.translationMatrix.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(8))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(311)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        var transformationMatrix = transform.getTransformationMatrix(sceneProps)
        var expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: cos(sin(12)), y: cos(tan(8)), z: abs(sin(311)))
        XCTAssert(transformationMatrix == expectedMatrix)
        
        transform.translationMatrix.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(1.12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(88))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(3)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        transformationMatrix = transform.getTransformationMatrix(sceneProps)
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: cos(sin(1.12)), y: cos(tan(88)), z: abs(sin(3)))
        XCTAssert(transformationMatrix == expectedMatrix)
    
        transform.rotationMatrix.setRotation(x: 1, y: 2, z: 3)
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: cos(sin(1.12)), y: cos(tan(88)), z: abs(sin(3)))
            * EGMatrixBuilder.createRotationMatrix(x: 1, y: 2, z: 3)
        transformationMatrix = transform.getTransformationMatrix(sceneProps)
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 122
        transform.scaleMatrix.setScale(
            x: EGUnaryOp(type: .sin, child: EGTime()),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGTime())),
            z: EGUnaryOp(type: .sin, child: EGTime())
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == false)
        transformationMatrix = transform.getTransformationMatrix(sceneProps)
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: cos(sin(1.12)), y: cos(tan(88)), z: abs(sin(3)))
            * EGMatrixBuilder.createRotationMatrix(x: 1, y: 2, z: 3)
            * EGMatrixBuilder.createScaleMatrix(x: sin(sceneProps.time), y: cos(cos(sceneProps.time)), z: sin(sceneProps.time))
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 15885
        transformationMatrix = transform.getTransformationMatrix(sceneProps)
        expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: cos(sin(1.12)), y: cos(tan(88)), z: abs(sin(3)))
            * EGMatrixBuilder.createRotationMatrix(x: 1, y: 2, z: 3)
            * EGMatrixBuilder.createScaleMatrix(x: sin(sceneProps.time), y: cos(cos(sceneProps.time)), z: sin(sceneProps.time))
        XCTAssert(transformationMatrix == expectedMatrix)
    }
}
