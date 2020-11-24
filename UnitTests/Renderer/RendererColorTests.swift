//
//  RendererColorTests.swift
//  UnitTests
//
//  Created by Michael Le on 2020-11-24.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class RendererColorTests: XCTestCase {
    var sceneProps: SceneProps!

    override func setUpWithError() throws {
        super.setUp()
        sceneProps = SceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }

    func testRColor() throws {
        let color = RColor()
        color.setColor(r: 1.0, g: 0.334, b: 0.232, a: 1.0)
        XCTAssert(color.evaluate(sceneProps) == simd_float4(1.0, 0.334, 0.232, 1.0))

        sceneProps.time = 2415.111
        color.setColor(
            r: RMBinaryOp(
                type: .sub,
                leftChild: RMBinaryOp(type: .add, leftChild: RMTime(), rightChild: RMTime()),
                rightChild: RMUnaryOp(type: .cos, child: RMConstant(1.22))
            ),
            g: RMBinaryOp(
                type: .add,
                leftChild: RMUnaryOp(type: .cos, child: RMTime()),
                rightChild: RMUnaryOp(type: .sin, child: RMConstant(1.2))
            ),
            b: RMConstant(0.4),
            a: RMConstant(0.1)
        )
        let r: Float = (sceneProps.time + sceneProps.time) - cos(1.22)
        let g: Float = cos(sceneProps.time) + sin(1.2)
        let b: Float = 0.4
        let a: Float = 0.1
        XCTAssert(color.evaluate(sceneProps) == simd_float4(r, g, b, a))
    }
}
