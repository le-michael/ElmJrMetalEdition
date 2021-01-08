//
//  ParserTests.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class EIParserTests: XCTestCase {
    func checkASTExpression(_ toParse: String, _ toOutput: String) throws {
        let ast = try EIParser(text: toParse).parseExpression()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func checkASTDeclaration(_ toParse: String, _ toOutput: String) throws {
        let ast = try EIParser(text: toParse).parseDeclaration()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func testIdentifier() throws {
        try checkASTExpression("foo", "foo")
        try checkASTExpression("(bar)", "bar")
        try checkASTExpression("(((moon)))", "moon")
    }
    
    func testMultiply() throws {
        try checkASTExpression("x*y", "(x*y)")
        try checkASTExpression("x*(y*z)","(x*(y*z))")
    }
    
    func testNegativeNumbers() throws {
        try checkASTExpression("-5", "-5")
        try checkASTExpression("1 + -5", "(1+-5)")
    }
    
    func testMath() throws {
        try checkASTExpression("(1+x)/(y*5.2)", "((1+x)/(y*5.2))")
    }
    
    func testBool() throws {
        try checkASTExpression("True","True")
        try checkASTExpression("False","False")
        try checkASTExpression("True || False","(True||False)")
        try checkASTExpression("False && True","(False&&True)")
        try checkASTExpression("not False","(not False)")
        try checkASTExpression("not True || False","((not True)||False)")
    }
    
    func testMakeFunction() throws {
        try checkASTDeclaration("x = 1", "x = 1")
        try checkASTDeclaration("addone x = x + 1", "addone x = (x+1)")
    }
    
    func testCallFunction() throws {
        try checkASTExpression("f 1", "(f 1)")
        try checkASTExpression("foo 1+1", "(foo (1+1))")
        try checkASTExpression("bar (foo 6) 3 5", "(bar (foo 6) 3 5)")
        try checkASTExpression("add x y", "(add x y)")
    }
    
    func testIfElse() throws {
        try checkASTExpression("if 1 then 2 else 3", "if 1 then 2 else 3")
        try checkASTExpression("if 1 then 2 else if 3 then 4 else 5", "if 1 then 2 else if 3 then 4 else 5")
        try checkASTExpression("if 1 then 2 else if 3 then 4 else if 5 then 6 else 7",
                               "if 1 then 2 else if 3 then 4 else if 5 then 6 else 7")
    }

}


