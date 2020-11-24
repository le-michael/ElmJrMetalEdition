//
//  testTokenCreation.swift
//  UnitTests
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition
class testTokenCreation: XCTestCase {
    func testIdentifier() throws {
        let x = Token(type:.identifier, raw:"foobar")
        assert(x.type == .identifier);
        assert(x.raw == "foobar");
    }
    
    func testNumberInteger() throws {
        let x = Token(type:.number, raw:"123456")
        assert(x.type == .number);
        assert(x.raw == "123456");
    }
    
    func testNumberFloat() throws {
        let x = Token(type:.number, raw:"123.456")
        assert(x.type == .number);
        assert(x.raw == "123.456");
    }
}
