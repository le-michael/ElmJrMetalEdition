//
//  TestLexer.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class TestLexer: XCTestCase {
    func testSymbols() throws {
        let s = "()+-++*^/'\"";
        let t:[Token.TokenType] = [
            .leftParan, .rightParan, .plus, .minus, .plusplus, .asterisk, .caret, .forwardSlash, .singlequote, .doublequote, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testWhitespace() throws {
        let s = " (  )   + ++    ";
        let t:[Token.TokenType] = [
            .leftParan, .rightParan, .plus, .plusplus, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testIdentifier() throws {
        let s = "a bc asd_ bird27";
        let t:[Token.TokenType] = [
            .identifier, .identifier, .identifier, .identifier, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testNumber() throws {
        let s = "1 987.456 5.0 800000";
        let t:[Token.TokenType] = [
            .number, .number, .number, .number, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testExpression() throws {
        let s = "(1 + x) + b2";
        let t:[Token.TokenType] = [
            .leftParan, .number, .plus, .identifier, .rightParan, .plus, .identifier, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
}
