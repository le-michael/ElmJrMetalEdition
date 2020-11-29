//
//  InterpreterTests.swift
//  UnitTests
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//
@testable import ElmJrMetalEdition
import XCTest

class InterpreterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseVariable() throws {
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
        /*
        for test in tests {
          print(try! parse(tokenize(text: test)))
        }
 */
    }
}
