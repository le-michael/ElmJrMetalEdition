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

    func testEGConstant() throws {
        var constant = EGConstant(2)
        XCTAssert(constant.evaluate(sceneProps) == 2)
        
        constant = EGConstant(2.4213)
        XCTAssert(constant.evaluate(sceneProps) == 2.4213)
        
        constant = EGConstant(-100.313)
        XCTAssert(constant.evaluate(sceneProps) == -100.313)
        XCTAssert(constant.usesTime() == false)
    }

    func testEGTime() throws {
        sceneProps.time = 1.312
        let time = EGTime()
        
        XCTAssert(time.evaluate(sceneProps) == 1.312)
        XCTAssert(time.usesTime() == true)
    }
    
    func testEGUnaryOp() throws {
        sceneProps.time = 1.563
        let sinEq = EGUnaryOp(type: .sin, child: EGTime())
        XCTAssert(sinEq.evaluate(sceneProps) == sin(1.563))
        XCTAssert(sinEq.usesTime() == true)
        
        let cosEq = EGUnaryOp(type: .cos, child: EGConstant(1.2))
        XCTAssert(cosEq.evaluate(sceneProps) == cos(1.2))
        XCTAssert(cosEq.usesTime() == false)
        
        
        let tanEq = EGUnaryOp(type: .tan, child: EGConstant(1.23))
        XCTAssert(tanEq.evaluate(sceneProps) == tan(1.23))
        XCTAssert(tanEq.usesTime() == false)
        
        
        let nestedEq = EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGConstant(1.222)))
        XCTAssert(nestedEq.evaluate(sceneProps) == cos(cos(1.222)))
        XCTAssert(nestedEq.usesTime() == false)
        
        cosEq.child = sinEq
        tanEq.child = cosEq
        sceneProps.time = 2.111
        
        let nesetedTimeEq = EGUnaryOp(type: .tan, child: tanEq)
        XCTAssert(nesetedTimeEq.evaluate(sceneProps) == tan(tan(cos(sin(2.111)))))
        XCTAssert(nesetedTimeEq.usesTime() == true)
        
        let negEq = EGUnaryOp(type: .neg, child: EGTime())
        XCTAssert(negEq.evaluate(sceneProps) == -sceneProps.time)
        XCTAssert(negEq.usesTime())
        
        let absEq = EGUnaryOp(type: .abs, child: EGConstant(-12.3333))
        XCTAssert(absEq.evaluate(sceneProps) == 12.3333)
        XCTAssert(absEq.usesTime() == false)
    }
    
    func testEGBinaryOp() throws {
        sceneProps.time = 123.222
        let addEq = EGBinaryOp(type: .add, leftChild: EGConstant(2.3), rightChild: EGTime())
        var expectedValue = 2.3 + sceneProps.time
        XCTAssert(addEq.evaluate(sceneProps) == expectedValue)
        XCTAssert(addEq.usesTime() == true)
        
        sceneProps.time = 1111.1123
        let subEq = EGBinaryOp(type: .sub, leftChild: EGConstant(1.2), rightChild: addEq)
        expectedValue = 1.2 - (2.3 + sceneProps.time)
        XCTAssert(subEq.evaluate(sceneProps) == expectedValue)
        XCTAssert(subEq.usesTime() == true)
        
        sceneProps.time = 1.233
        let mulEq = EGBinaryOp(type: .mul, leftChild: subEq, rightChild: addEq)
        expectedValue = (1.2 - (2.3 + sceneProps.time)) * (2.3 + sceneProps.time)
        XCTAssert(mulEq.evaluate(sceneProps) == expectedValue)
        XCTAssert(mulEq.usesTime() == true)
        
        sceneProps.time = 1.3244
        let divEq = EGBinaryOp(type: .div, leftChild: EGConstant(14.22), rightChild: EGTime())
        expectedValue = 14.22 / sceneProps.time
        XCTAssert(divEq.evaluate(sceneProps) == expectedValue)
        XCTAssert(divEq.usesTime() == true)
        
        let maxEq = EGBinaryOp(type: .max, leftChild: EGConstant(14.22), rightChild: EGConstant(12.0))
        XCTAssert(maxEq.evaluate(sceneProps) == 14.22)
        XCTAssert(maxEq.usesTime() == false)
        
        let minEq = EGBinaryOp(type: .min, leftChild: EGConstant(14.22), rightChild: EGConstant(12.0))
        XCTAssert(minEq.evaluate(sceneProps) == 12.0)
        XCTAssert(minEq.usesTime() == false)
    }
    
    func testEGRandom() throws {
        for _ in 0...1000 {
            let randEq = EGRandom()
            XCTAssert(randEq.evaluate(sceneProps) < 100 && randEq.evaluate(sceneProps) >= 0)
        }
        
        for _ in 0...1000 {
            let randEq = EGRandom(range: 3 ..< 5)
            XCTAssert(randEq.evaluate(sceneProps) < 5 && randEq.evaluate(sceneProps) >= 3)
        }
        
        let randEq = EGRandom()
        XCTAssert(randEq.usesTime() == false)
    }
}
