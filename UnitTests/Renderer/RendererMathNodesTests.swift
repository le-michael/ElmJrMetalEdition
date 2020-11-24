//
//  RendererMathNodesTests.swift
//  UnitTestTargets
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class RendererMathNodesTests: XCTestCase {
    var sceneProps: SceneProps!

    override func setUpWithError() throws {
        super.setUp()
        sceneProps = SceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }

    func testRMConstant() throws {
        var constant = RMConstant(2)
        XCTAssert(constant.evaluate(sceneProps) == 2)
        
        constant = RMConstant(2.4213)
        XCTAssert(constant.evaluate(sceneProps) == 2.4213)
        
        constant = RMConstant(-100.313)
        XCTAssert(constant.evaluate(sceneProps) == -100.313)
    }

    func testRMTime() throws {
        sceneProps.time = 1.312
        let time = RMTime()
        
        XCTAssert(time.evaluate(sceneProps) == 1.312)
    }
    
    func testRMUnaryOp() throws {
        sceneProps.time = 1.563
        let sinEq = RMUnaryOp(type: .sin, child: RMTime())
        XCTAssert(sinEq.evaluate(sceneProps) == sin(1.563))
        
        let cosEq = RMUnaryOp(type: .cos, child: RMConstant(1.2))
        XCTAssert(cosEq.evaluate(sceneProps) == cos(1.2))
        
        let tanEq = RMUnaryOp(type: .tan, child: RMConstant(1.23))
        XCTAssert(tanEq.evaluate(sceneProps) == tan(1.23))
        
        let nestedEq = RMUnaryOp(type: .cos, child: RMUnaryOp(type: .cos, child: RMConstant(1.222)))
        XCTAssert(nestedEq.evaluate(sceneProps) == cos(cos(1.222)))
     
        cosEq.child = sinEq
        tanEq.child = cosEq
        sceneProps.time = 2.111
        
        let nesetedTimeEq = RMUnaryOp(type: .tan, child: tanEq)
        XCTAssert(nesetedTimeEq.evaluate(sceneProps) == tan(tan(cos(sin(2.111)))))
        
        let negEq = RMUnaryOp(type: .neg, child: RMTime())
        XCTAssert(negEq.evaluate(sceneProps) == -sceneProps.time)
        
        let absEq = RMUnaryOp(type: .abs, child: RMConstant(-12.3333))
        XCTAssert(absEq.evaluate(sceneProps) == 12.3333)
    }
    
    func testRMBinaryOp() throws {
        sceneProps.time = 123.222
        let addEq = RMBinaryOp(type: .add, leftChild: RMConstant(2.3), rightChild: RMTime())
        var expectedValue = 2.3 + sceneProps.time
        XCTAssert(addEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1111.1123
        let subEq = RMBinaryOp(type: .sub, leftChild: RMConstant(1.2), rightChild: addEq)
        expectedValue = 1.2 - (2.3 + sceneProps.time)
        XCTAssert(subEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1.233
        let mulEq = RMBinaryOp(type: .mul, leftChild: subEq, rightChild: addEq)
        expectedValue = (1.2 - (2.3 + sceneProps.time)) * (2.3 + sceneProps.time)
        XCTAssert(mulEq.evaluate(sceneProps) == expectedValue)
        
        sceneProps.time = 1.3244
        let divEq = RMBinaryOp(type: .div, leftChild: RMConstant(14.22), rightChild: RMTime())
        expectedValue = 14.22 / sceneProps.time
        XCTAssert(divEq.evaluate(sceneProps) == expectedValue)
    }
}
