//
//  EITypeInferencerTests.swift
//  UnitTests
//
//  Created by Lucas Dutton on 2020-12-10.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import XCTest
@testable import ElmJrMetalEdition

class EITypeInferencerTests: XCTestCase {
    func checkSimpleExpressionTy(_ toEvaluate : String, _ toOutput : String)
        throws {
        let ast = try EIParser(text: toEvaluate).parseExpression()
        let tyEnv = try EITypeInferencer(parsed : ["x" : ast]).inferTop()
        XCTAssertEqual("\(tyEnv)", toOutput)
    }
    
    func testLiteralTypes() throws {
        try checkSimpleExpressionTy("3", "unimplemented")
    }
}
