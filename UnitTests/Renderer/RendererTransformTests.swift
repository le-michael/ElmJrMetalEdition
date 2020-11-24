//
//  RendererTransformTests.swift
//  UnitTests
//
//  Created by Michael Le on 2020-11-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class RendererTransformTests: XCTestCase {
    var sceneProps: SceneProps!
    
    override func setUpWithError() throws {
        super.setUp()
        sceneProps = SceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }
    
    func testScaleMatrix() throws {
        let scaleMatrix = ScaleMatrix()
        scaleMatrix.setScale(x: 1, y: 2, z: 3)
        var expectedMatrix = createScaleMatrix(x: 1, y: 2, z: 3)
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
        
        sceneProps.time = 123.2222
        scaleMatrix.setScale(
            x: RMConstant(10.22),
            y: RMUnaryOp(type: .cos, child: RMTime()),
            z: RMUnaryOp(type: .sin, child: RMTime())
        )
        expectedMatrix = createScaleMatrix(
            x: 10.22,
            y: cos(sceneProps.time),
            z: sin(sceneProps.time)
        )
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
    
        sceneProps.time = 111.2222
        scaleMatrix.setScale(
            x: RMUnaryOp(type: .cos, child: RMUnaryOp(type: .sin, child: RMTime())),
            y: RMUnaryOp(type: .tan, child: RMTime()),
            z: RMUnaryOp(type: .sin, child: RMUnaryOp(type: .tan, child: RMConstant(2.33)))
        )
        expectedMatrix = createScaleMatrix(
            x: cos(sin(sceneProps.time)),
            y: tan(sceneProps.time),
            z: sin(tan(2.33))
        )
        XCTAssert(scaleMatrix.evaluate(sceneProps) == expectedMatrix)
    }
    
    func testTranslationMatrix() throws {
        let translationMatrix = TranslationMatrix()
        translationMatrix.setTranslation(x: 1, y: 10.2, z: 32.1)
        var expectedMatrix = createTranslationMatrix(x: 1, y: 10.2, z: 32.1)
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        
        sceneProps.time = 1.22223
        translationMatrix.setTranslation(
            x: RMConstant(1.22),
            y: RMTime(),
            z: RMUnaryOp(type: .cos, child: RMTime())
        )
        expectedMatrix = createTranslationMatrix(
            x: 1.22,
            y: sceneProps.time,
            z: cos(sceneProps.time)
        )
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
        
        sceneProps.time = 2123.222
        translationMatrix.setTranslation(
            x: RMUnaryOp(type: .cos, child: RMUnaryOp(type: .tan, child: RMTime())),
            y: RMUnaryOp(type: .sin, child: RMUnaryOp(type: .sin, child: RMConstant(1.22))),
            z: RMUnaryOp(type: .cos, child: RMUnaryOp(type: .cos, child: RMTime()))
        )
        expectedMatrix = createTranslationMatrix(
            x: cos(tan(sceneProps.time)),
            y: sin(sin(1.22)),
            z: cos(cos(sceneProps.time))
        )
        XCTAssert(translationMatrix.evaluate(sceneProps) == expectedMatrix)
    }
    
    func testZRotationMatrix() throws {
        let zRotationMatrix = ZRotationMatrix()
        zRotationMatrix.setZRotation(angle: 1.222)
        var expectedMatrix = createZRotationMatrix(radians: 1.222)
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)

        sceneProps.time = 1.4231
        zRotationMatrix.setZRotation(angle: RMTime())
        expectedMatrix = createZRotationMatrix(radians: sceneProps.time)
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)

        zRotationMatrix.setZRotation(
            angle: RMUnaryOp(type: .cos, child: RMUnaryOp(type: .sin, child: RMTime()))
        )
        expectedMatrix = createZRotationMatrix(radians: cos(sin(sceneProps.time)))
        XCTAssert(zRotationMatrix.evaluate(sceneProps) == expectedMatrix)
    }
}
