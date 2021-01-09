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
    func checkExprTy(_ toEvaluate : String, _ toOutput : String)
        throws {
        let ast = try EIParser(text: toEvaluate).parseExpression()
        let tyEnv = try EITypeInferencer(parsed : [ast]).inferTop()
        XCTAssertEqual("\(try tyEnv.lookup("\(ast.description)").description)", toOutput)
    }
    
    func testLiteralTypes() throws {
        try checkExprTy("3", "number")
        try checkExprTy("3.5", "Float")
    }
    
    func testOperators() throws {
        try checkExprTy("3+4", "number")
        try checkExprTy("3.5+4", "Float")
        // variables unimplemented
        // try checkSimpleExpressionTy("3+x", "number")
        // try checkSimpleExpressionTy("x+y", "number")
        // try checkSimpleExpressionTy(("2.0+x"), "Float")
    }
    
    func testIfElse() throws {
        try checkExprTy("if True then 1 else 2", "number")
    }
}
