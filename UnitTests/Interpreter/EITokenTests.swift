//
//  testTokenCreation.swift
//  UnitTests
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import XCTest

class EITokenTests: XCTestCase {
    func testIdentifier() throws {
        let tk = EIToken(type: .identifier, raw: "foobar")
        XCTAssert(tk.type == .identifier)
        XCTAssert(tk.raw == "foobar")
    }

    func testNumberInteger() throws {
        let tk = EIToken(type: .number, raw: "123456")
        XCTAssert(tk.type == .number)
        XCTAssert(tk.raw == "123456")
    }

    func testNumberFloat() throws {
        let tk = EIToken(type: .number, raw: "123.456")
        XCTAssert(tk.type == .number)
        XCTAssert(tk.raw == "123.456")
    }
}
