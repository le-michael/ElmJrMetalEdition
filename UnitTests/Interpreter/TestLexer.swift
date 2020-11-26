//
//  TestLexer.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class LexerTests: XCTestCase {
    func testSymbols() throws {
        let s = "()+-++*^/'\": ::->{}<||>.|";
        let t:[Token.TokenType] = [
            .leftParan, .rightParan, .plus, .minus, .plusplus, .asterisk, .caret, .forwardSlash, .singlequote, .doublequote, .colon, .coloncolon, .arrow, .leftCurly, .rightCurly, .leftFuncApp, .rightFuncApp, .dot, .bar, .endOfFile]
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
    
    func testReservedWords() throws {
        let s = "if then else case of let in type alias ifcat";
        
        let t:[Token.TokenType] = [
            .IF, .THEN, .ELSE, .CASE, .OF, .LET, .IN, .TYPE, .ALIAS, .identifier, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testLetterAfterDigit() throws {
        let s = "1234A"
        let l = Lexer(text: s)
        XCTAssertThrowsError(try l.nextToken()) { (error) in
            XCTAssertEqual(error as! Lexer.LexerError, Lexer.LexerError.UnexpectedCharacter("A"))
        }
    }
    
    func testNumberTwoDecimal() throws {
        let s = "1234.456.789"
        let l = Lexer(text: s)
        XCTAssertThrowsError(try l.nextToken()) { (error) in
            XCTAssertEqual(error as! Lexer.LexerError, Lexer.LexerError.InvalidNumber)
        }
    }
    
    func testNewlines() throws {
        let s = "1 \n a \n + \n \n";
        let t:[Token.TokenType] = [
            .number, .identifier, .plus, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testSingleLineComments() throws {
        let s = "( \n -- a \n = -- + \n";
        let t:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testBlockComments() throws {
        let s = "( \n {- a -} \n = {- + -} \n";
        let t:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testBlockCommentsNested() throws {
        let s = "( \n {- {- a -} b -} \n = {- {--} {--} + -} \n";
        let t:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testSyntaxExample1() throws {
        let s = "{--} \n add x y = x + y \n --} \n";
        let t:[Token.TokenType] = [
            .identifier, .identifier, .identifier, .equal, .identifier, .plus, .identifier, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testSyntaxExample2() throws {
        let s = "\"abc\" ++ \"def\"";
        let t:[Token.TokenType] = [
            .doublequote, .identifier, .doublequote, .plusplus, .doublequote, .identifier, .doublequote, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    func testSyntaxExample3() throws {
        let s = "if powerLevel > 9000 then [] else 1 :: [2,3]";
        let t:[Token.TokenType] = [
            .IF, .identifier, .greaterthan, .number, .THEN, .leftSquare, .rightSquare, .ELSE, .number, .coloncolon, .leftSquare, .number, .comma, .number, .rightSquare, .endOfFile]
        let l = Lexer(text: s)
        for type in t {
            let v = try l.nextToken()
            XCTAssert(v.type == type)
        }
    }
    
    
    
    
    
    
    
}
