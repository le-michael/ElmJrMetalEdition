//
//  EGMathNodesTests.swift
//  UnitTestTargets
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class EGMathNodesTests: XCTestCase {
    var sceneProps: EGSceneProps!

    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }

    func testEGFloatConstant() throws {
        var constant = EGFloatConstant(2)
        XCTAssert(constant.evaluate(sceneProps) == 2)
        
        constant = EGFloatConstant(2.4213)
        XCTAssert(constant.evaluate(sceneProps) == 2.4213)
        
        constant = EGFloatConstant(-100.313)
        XCTAssert(constant.evaluate(sceneProps) == -100.313)
    }

    func testEGTime() throws {
        sceneProps.time = 1.312
        let time = EGTime()
        
        XCTAssert(time.evaluate(sceneProps) == 1.312)
    }
    
    func testEGUnaryOp() throws {
        sceneProps.time = 1.563
        let sinEq = EGUnaryOp(type: .sin, child: EGTime())
        XCTAssert(sinEq.evaluate(sceneProps) == sin(1.563))
        
        let cosEq = EGUnaryOp(type: .cos, child: EGFloatConstant(1.2))
        XCTAssert(cosEq.evaluate(sceneProps) == cos(1.2))
        
        let tanEq = EGUnaryOp(type: .tan, child: EGFloatConstant(1.23))
        XCTAssert(tanEq.evaluate(sceneProps) == tan(1.23))
        
        let nestedEq = EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGFloatConstant(1.222)))
        XCTAssert(nestedEq.evaluate(sceneProps) == cos(cos(1.222)))
     
        cosEq.child = sinEq
        tanEq.child = cosEq
        sceneProps.time = 2.111
        
        let nesetedTimeEq = EGUnaryOp(type: .tan, child: tanEq)
        XCTAssert(nesetedTimeEq.evaluate(sceneProps) == tan(tan(cos(sin(2.111)))))
        
        let negEq = EGUnaryOp(type: .neg, child: EGTime())
        XCTAssert(negEq.evaluate(sceneProps) == -sceneProps.time)
        
        let absEq = EGUnaryOp(type: .abs, child: EGFloatConstant(-12.3333))
        XCTAssert(absEq.evaluate(sceneProps) == 12.3333)
    }
    
    func testEGBinaryOp() throws {
        sceneProps.time = 123.222
        let addEq = EGBinaryOp(type: .add, leftChild: EGFloatConstant(2.3), rightChild: EGTime())
        var expectedValue = 2.3 + sceneProps.time
        XCTAssert(addEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1111.1123
        let subEq = EGBinaryOp(type: .sub, leftChild: EGFloatConstant(1.2), rightChild: addEq)
        expectedValue = 1.2 - (2.3 + sceneProps.time)
        XCTAssert(subEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1.233
        let mulEq = EGBinaryOp(type: .mul, leftChild: subEq, rightChild: addEq)
        expectedValue = (1.2 - (2.3 + sceneProps.time)) * (2.3 + sceneProps.time)
        XCTAssert(mulEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1.3244
        let divEq = EGBinaryOp(type: .div, leftChild: EGFloatConstant(14.22), rightChild: EGTime())
        expectedValue = 14.22 / sceneProps.time
        XCTAssert(divEq.evaluate(sceneProps) == expectedValue)
    }
}
