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

class EGTransformPropertyTests: XCTestCase {
    var sceneProps: EGSceneProps!
    
    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }
    
    func testEGScaleMatrix() throws {
        let scaleMatrix = EGScaleMatrix()
        scaleMatrix.setScale(x: 1, y: 2, z: 3)
        var expectedMatrix = EGMatrixBuilder.createScaleMatrix(x: 1, y: 2, z: 3)
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
        
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
    }
    
    func testEGTranslationMatrix() throws {
        let translationMatrix = EGTranslationMatrix()
        translationMatrix.setTranslation(x: 1, y: 10.2, z: 32.1)
        var expectedMatrix = EGMatrixBuilder.createTranslationMatrix(x: 1, y: 10.2, z: 32.1)
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        
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
    }
    
    func testEGZRotationMatrix() throws {
        let zRotationMatrix = EGZRotationMatrix()
        zRotationMatrix.setZRotation(angle: 1.222)
        var expectedMatrix = EGMatrixBuilder.createZRotationMatrix(radians: 1.222)
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)

        sceneProps.time = 1.4231
        zRotationMatrix.setZRotation(angle: EGTime())
        expectedMatrix = EGMatrixBuilder.createZRotationMatrix(radians: sceneProps.time)
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)

        zRotationMatrix.setZRotation(
            angle: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGTime()))
        )
        expectedMatrix = EGMatrixBuilder.createZRotationMatrix(radians: cos(sin(sceneProps.time)))
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)
    }
}
