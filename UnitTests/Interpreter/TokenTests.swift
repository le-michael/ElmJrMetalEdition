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
        let tk = Token(type:.identifier, raw:"foobar")
        XCTAssert(tk.type == .identifier);
        XCTAssert(tk.raw == "foobar");
    }
    
    func testNumberInteger() throws {
        let tk = Token(type:.number, raw:"123456")
        XCTAssert(tk.type == .number);
        XCTAssert(tk.raw == "123456");
    }
    
    func testNumberFloat() throws {
        let tk = Token(type:.number, raw:"123.456")
        XCTAssert(tk.type == .number);
        XCTAssert(tk.raw == "123.456");
    }
}
