//
//  ParserTests.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class ParserTests: XCTestCase {
    func checkASTExpression(_ toParse: String, _ toOutput: String) throws {
        let ast = try Parser(text: toParse).parseExpression()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func checkASTDeclaration(_ toParse: String, _ toOutput: String) throws {
        let ast = try Parser(text: toParse).parseDeclaration()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func testIdentifier() throws {
        try checkASTExpression("foo", "FunctionCall(\"foo\")")
        try checkASTExpression("(bar)", "FunctionCall(\"bar\")")
        try checkASTExpression("(((moon)))", "FunctionCall(\"moon\")")
    }
    
    func testMultiply() throws {
        try checkASTExpression("x*y", "BinaryOpMultiply(FunctionCall(\"x\"),FunctionCall(\"y\"))")
        try checkASTExpression("x*(y*z)", "BinaryOpMultiply(FunctionCall(\"x\"),BinaryOpMultiply(FunctionCall(\"y\"),FunctionCall(\"z\")))")
    }
    
    func testMath() throws {
        try checkASTExpression("(1+x)/(y*5)", "BinaryOpDivide(BinaryOpAdd(Integer(1),FunctionCall(\"x\")),BinaryOpMultiply(FunctionCall(\"y\"),Integer(5)))")
    }
    
    func testMakeFunction() throws {
        try checkASTDeclaration("x = 1", "x([]){Integer(1)}")
        try checkASTDeclaration("addone x = x + 1", "addone([\"x\"]){BinaryOpAdd(FunctionCall(\"x\"),Integer(1))}")
    }
    
    func testCallFunction() throws {
        try checkASTExpression("f 1", "FunctionCall(\"f,[Integer(1)]\")")
        try checkASTExpression("foo 1+1", "FunctionCall(\"foo,[BinaryOpAdd(Integer(1),Integer(1))]\")")
        try checkASTExpression("bar (foo 6) 3 5", "FunctionCall(\"bar,[FunctionCall(\"foo,[Integer(6)]\"), Integer(3), Integer(5)]\")")
        try checkASTExpression("add x y", "FunctionCall(\"add,[FunctionCall(\"x\"), FunctionCall(\"y\")]\")")
    }

}


