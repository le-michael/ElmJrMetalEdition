//
//  EvaluatorTests.swift
//  UnitTests
//
//  Created by user186747 on 12/4/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class EIEvaluatorTests: XCTestCase {
    func checkEvaluateExpression(_ toEvaluate: String, _ toOutput: String) throws {
        let ast = try EIParser(text: toEvaluate).parseExpression()
        let result = try EIEvaluator().evaluate(ast, [:])
        XCTAssertEqual("\(result)", toOutput)
    }
    
    func checkInterpret(_ toInterpret: [String], _ toOutput: [String]) throws {
        XCTAssertEqual(toInterpret.count, toOutput.count)
        let evaluator = EIEvaluator()
        for i in 0..<toInterpret.count {
            let result = try evaluator.interpret(toInterpret[i])
            XCTAssertEqual("\(result)", toOutput[i])
        }
    }
    
    func checkCompile(_ toCompile: String, _ toOutput: String) throws {
        let view = try EIEvaluator().compile(toCompile)
        XCTAssertEqual("\(view)", toOutput)
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
    
    func testEqualityOperators() throws {
        try checkEvaluateExpression("1 == 1", "True")
        try checkEvaluateExpression("1 == 2", "False")
        try checkEvaluateExpression("1 /= 1", "False")
        try checkEvaluateExpression("1 <= 1", "True")
        try checkEvaluateExpression("1 >= 1", "True")
        try checkEvaluateExpression("1 < 1", "False")
        try checkEvaluateExpression("1 > 1", "False")
        try checkEvaluateExpression("1 + 3 == 4", "True")
    }
    
    func testInterpret() throws {
        try checkInterpret(["1+1"],["2"])
        try checkInterpret(["x = 1"],["x = 1"])
        try checkInterpret(["x = 1", "(x)"], ["x = 1","1"])
        try checkInterpret(["x = 1","y = 2","(x + y)"], ["x = 1","y = 2","3"])
    }
    
    func testSimpleFunctionCalls() throws {
        try checkInterpret(["f x = x + 1", "(f 1)"],["f x = (x+1)", "2"])
        try checkInterpret(["f x = x + 1", "(f(f(f 1)))"],["f x = (x+1)", "4"])
        try checkInterpret(["f x y = x + y", "(f 1 2)"], ["f x y = (x+y)", "3"])
        try checkInterpret(["f x = x + 1", "(f (1+1))"],["f x = (x+1)", "3"])
    }
    
    func testPassingFunction() throws {
        // TODO: This test requires implementing partial function application & changing functions so they are not stored with a name. (Why? If you store a function with a name, then pass that function as a value, the name is no longer accurate)
        /*
        try checkInterpret(["f g x = (g x) + (g x)","h x = 3*x","(f h 5)"],
                           ["f g x = ((g x)+(g x))","h x = (3*x)","30"])
        */
    }
    
    func testAndOrNot() throws {
        try checkEvaluateExpression("True","True")
        try checkEvaluateExpression("False","False")
        try checkEvaluateExpression("True || False","True")
        try checkEvaluateExpression("False && True","False")
        try checkEvaluateExpression("not False","True")
        try checkEvaluateExpression("not True || False","False")
    }
    
    func testIfElse() throws {
        try checkEvaluateExpression("if True then 1 else 2","1")
        try checkEvaluateExpression("if False then 1 else 2","2")
        try checkEvaluateExpression("if False then 1 else if True then 2 else 3", "2")
        try checkEvaluateExpression("if 2 == 1+1 then 7 else 8", "7")
    }
    
    func testRecursion() throws {
        try checkInterpret(["fib x = if x==0 || x==1 then 1 else fib (x-1) + fib (x-2)","(fib 0)","(fib 1)","(fib 2)","(fib 3)","(fib 4)","(fib 5)"], ["fib x = if ((x==0)||(x==1)) then 1 else ((fib (x-1))+(fib (x-2)))","1","1","2","3","5","8"])
    }
    
    func testSimpleMultiline() throws {
        try checkCompile("x = 1\ny = 2\nview=x+y", "3")
        try checkCompile("f x = x + 1\nview=(f 3)\nz=2", "4")
    }
    
    


}
