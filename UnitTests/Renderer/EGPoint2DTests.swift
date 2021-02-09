//
//  EGPoint2D.swift
//  UnitTests
//
//  Created by Michael Le on 2020-12-01.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class EGPoint2DTests: XCTestCase {
    var sceneProps: EGSceneProps!

    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps()
    }

    func testPoint2DEvaluate() throws {
        let p0 = EGPoint2D(x: 2.002, y: 3.033)
        XCTAssert(p0.evaluate(sceneProps) == simd_float2(2.002, 3.033))

        sceneProps.time = 14.3
        let p1 = EGPoint2D(
            x: EGTime(),
            y: EGBinaryOp(
                type: .mul,
                leftChild: EGConstant(20),
                rightChild: EGUnaryOp(type: .sin, child: EGTime())
            )
        )
        XCTAssert(p1.evaluate(sceneProps) == simd_float2(14.3, 20 * sin(14.3)))
    }
}
