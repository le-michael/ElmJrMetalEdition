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
    func checkASTString(_ toParse: String, _ toOutput: String) throws {
        let ast = try Parser(text: toParse).parseExpression()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func testIdentifier() throws {
        try checkASTString("foo", "Variable(\"foo\")")
        try checkASTString("(bar)", "Variable(\"bar\")")
        try checkASTString("(((moon)))", "Variable(\"moon\")")
    }
    
    func testMultiply() throws {
        try checkASTString("x*y", "BinaryOpMultiply(Variable(\"x\"),Variable(\"y\"))")
        try checkASTString("x*(y*z)", "BinaryOpMultiply(Variable(\"x\"),BinaryOpMultiply(Variable(\"y\"),Variable(\"z\")))")
    }
    
    func testMath() throws {
        try checkASTString("(1+x)/(y*5)", "BinaryOpDivide(BinaryOpAdd(Integer(1),Variable(\"x\")),BinaryOpMultiply(Variable(\"y\"),Integer(5)))")
    }

}


