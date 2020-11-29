//
//  testTokenCreation.swift
//  UnitTests
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class TokenTests: XCTestCase {
    func testIdentifier() throws {
        let x = Token(type:.identifier, raw:"foobar")
        XCTAssert(x.type == .identifier);
        XCTAssert(x.raw == "foobar");
    }
    
    func testNumberInteger() throws {
        let x = Token(type:.number, raw:"123456")
        XCTAssert(x.type == .number);
        XCTAssert(x.raw == "123456");
    }
    
    func testNumberFloat() throws {
        let x = Token(type:.number, raw:"123.456")
        XCTAssert(x.type == .number);
        XCTAssert(x.raw == "123.456");
    }
}
