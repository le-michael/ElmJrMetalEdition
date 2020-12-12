//
//  TestLexer.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import XCTest
@testable import ElmJrMetalEdition

class EILexerTests: XCTestCase {
    func checkTokenTypes(_ text: String, _ tokenTypes:[Token.TokenType]) throws {
        let lexer = EILexer(text: text)
        for tokenType in tokenTypes {
            let token = try lexer.nextToken()
            XCTAssert(token.type == tokenType)
        }
    }
    
    
    func testSymbols() throws {
        let text = "()+-++*^/: ::->{}<||>.|";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .rightParan, .plus, .minus, .plusplus, .asterisk, .caret, .forwardSlash, .colon, .coloncolon, .arrow, .leftCurly, .rightCurly, .leftFuncApp, .rightFuncApp, .dot, .bar, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testWhitespace() throws {
        let text = " (  )   + ++    ";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .rightParan, .plus, .plusplus, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testIdentifier() throws {
        let text = "a bc asd_ bird27";
        let tokenTypes:[Token.TokenType] = [
            .identifier, .identifier, .identifier, .identifier, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testNumber() throws {
        let text = "1 987.456 5.0 800000";
        let tokenTypes:[Token.TokenType] = [
            .number, .number, .number, .number, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testExpression() throws {
        let text = "(1 + x) + b2";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .number, .plus, .identifier, .rightParan, .plus, .identifier, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testReservedWords() throws {
        let text = "if then else case of let in type alias ifcat";
        let tokenTypes:[Token.TokenType] = [
            .IF, .THEN, .ELSE, .CASE, .OF, .LET, .IN, .TYPE, .ALIAS, .identifier, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testLetterAfterDigit() throws {
        let text = "1234A"
        let lexer = EILexer(text: text)
        XCTAssertThrowsError(try lexer.nextToken()) { (error) in
            XCTAssertEqual(error as! EILexer.LexerError, EILexer.LexerError.UnexpectedCharacter("A"))
        }
    }
    
    func testNumberTwoDecimal() throws {
        let text = "1234.456.789"
        let lexer = EILexer(text: text)
        XCTAssertThrowsError(try lexer.nextToken()) { (error) in
            XCTAssertEqual(error as! EILexer.LexerError, EILexer.LexerError.InvalidNumber)
        }
    }
    
    func testNewlines() throws {
        let text = "1 \n a \n + \n \n";
        let tokenTypes:[Token.TokenType] = [
            .number, .identifier, .plus, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testSingleLineComments() throws {
        let text = "( \n -- a \n = -- + \n";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testBlockComments() throws {
        let text = "( \n {- a -} \n = {- + -} \n";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testBlockCommentsNested() throws {
        let text = "( \n {- {- a -} b -} \n = {- {--} {--} + -} \n";
        let tokenTypes:[Token.TokenType] = [
            .leftParan, .equal, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testStringChar() throws {
        let text = "\"cat\" ++ 's'";
        let tokenTypes:[Token.TokenType] = [
            .string, .plusplus, .char, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testSyntaxExample1() throws {
        let text = "{--} \n add x y = x + y \n --} \n";
        let tokenTypes:[Token.TokenType] = [
            .identifier, .identifier, .identifier, .equal, .identifier, .plus, .identifier, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testSyntaxExample2() throws {
        let text = "\"abc\" ++ \"def\"";
        let tokenTypes:[Token.TokenType] = [
            .string, .plusplus, .string, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    func testSyntaxExample3() throws {
        let text = "if powerLevel > 9000 then [] else 1 :: [2,3]";
        let tokenTypes:[Token.TokenType] = [
            .IF, .identifier, .greaterthan, .number, .THEN, .leftSquare, .rightSquare, .ELSE, .number, .coloncolon, .leftSquare, .number, .comma, .number, .rightSquare, .endOfFile]
        try checkTokenTypes(text, tokenTypes);
    }
    
    
    
    
    
    
    
}
