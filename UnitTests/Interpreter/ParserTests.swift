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
    
    func testIdentifier1() throws {
        try checkASTString("foo", "Variable(\"foo\")")
    }

}
/*
 let tests = [
   "foo",
   "(bar)",
   "(((moo)))",
   "x*y",
   "x*(y*z)",
   "a + b*c + d*(e + f + g)",
   "a + 1",
   "(2 + y * 5 + 123) * (4/fooBar - 2)",
 ]
 
 */
