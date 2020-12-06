//
//  EvaluatorTests.swift
//  UnitTests
//
//  Created by user186747 on 12/4/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class EvaluatorTests: XCTestCase {
    func checkEvaluateExpression(_ toEvaluate: String, _ toOutput: String) throws {
        let ast = try Parser(text: toEvaluate).parseExpression()
        let result = try Evaluator().evaluate(ast, [:])
        XCTAssertEqual("\(result)", toOutput)
    }
    
    func checkInterpret(_ toInterpret: String, _ toOutput: String) throws {
        let result = try Evaluator().interpret(toInterpret)
        XCTAssertEqual("\(result)", toOutput)
    }
    
    func testLiteral() throws {
        try checkEvaluateExpression("1","1")
        try checkEvaluateExpression("2.73","2.73")
        try checkEvaluateExpression("-5", "-5")
    }
    
    func testSimpleMath() throws {
        try checkEvaluateExpression("1+1", "2")
        try checkEvaluateExpression("1 + -5", "-4")
        try checkEvaluateExpression("4+5+6", "15")
        try checkEvaluateExpression("1.5+4.5", "6.0")
        try checkEvaluateExpression("2.9+3", "5.9")
        try checkEvaluateExpression("(2 + 3)*6", "30")
        try checkEvaluateExpression("1*2 + 3*4 + 6/2", "17")
        try checkEvaluateExpression("5.0/2", "2.5")
    }
    
    func testInterpret() throws {
        try checkInterpret("1+1","2")
        try checkInterpret("x = 1","x = 1")
    }


}
