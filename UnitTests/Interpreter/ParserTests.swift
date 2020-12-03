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
    func testIdentifier() throws {
        let s = "foo"
        let ast = try Parser(text:s).parseExpression()
        XCTAssertEqual("\(ast)","Variable(\"foo\")")
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
