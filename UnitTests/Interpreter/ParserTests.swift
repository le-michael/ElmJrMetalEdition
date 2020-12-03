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
        try checkASTExpression("foo", "Variable(\"foo\")")
        try checkASTExpression("(bar)", "Variable(\"bar\")")
        try checkASTExpression("(((moon)))", "Variable(\"moon\")")
    }
    
    func testMultiply() throws {
        try checkASTExpression("x*y", "BinaryOpMultiply(Variable(\"x\"),Variable(\"y\"))")
        try checkASTExpression("x*(y*z)", "BinaryOpMultiply(Variable(\"x\"),BinaryOpMultiply(Variable(\"y\"),Variable(\"z\")))")
    }
    
    func testMath() throws {
        try checkASTExpression("(1+x)/(y*5)", "BinaryOpDivide(BinaryOpAdd(Integer(1),Variable(\"x\")),BinaryOpMultiply(Variable(\"y\"),Integer(5)))")
    }
    
    func testMakeFunction() throws {
        try checkASTDeclaration("x = 1", "x([]){Integer(1)}")
        try checkASTDeclaration("addone x = x + 1", "addone([\"x\"]){BinaryOpAdd(Variable(\"x\"),Integer(1))}")
    }

}


