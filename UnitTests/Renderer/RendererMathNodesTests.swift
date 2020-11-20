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
    }
}
