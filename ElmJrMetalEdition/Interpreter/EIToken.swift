//
//  Token.swift
//  ElmJrMetalEdition
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

struct EIToken {
    var type: TokenType;
    var raw: String;
    
    enum TokenType {
        case leftParan, rightParan, plus, plusplus, minus, asterisk, caret, forwardSlash, singlequote, doublequote, endOfFile, equal, equalequal, notequal, greaterthan, lessthan, greaterequal, lessequal, colon, coloncolon, arrow, leftCurly, rightCurly, leftSquare, rightSquare, leftFuncApp, rightFuncApp, dot, comma, bar, barbar, ampersandampersand, not
        case string, char
        case IF, THEN, ELSE, CASE, OF, LET, IN, TYPE, ALIAS
        case identifier
        case number
        case newline
    }
    
    static let symbols : [String: TokenType] = [
        "(":.leftParan,
        ")":.rightParan,
        "+":.plus,
        "++":.plusplus,
        "-":.minus,
        "*":.asterisk,
        "^":.caret,
        "/":.forwardSlash,
        "'":.singlequote,
        "\"":.doublequote,
        "=":.equal,
        "==":.equalequal,
        "/=":.notequal,
        ">":.greaterthan,
        "<":.lessthan,
        ">=":.greaterequal,
        "<=":.lessequal,
        ":":.colon,
        "::":.coloncolon,
        "->":.arrow,
        "{":.leftCurly,
        "}":.rightCurly,
        "[":.leftSquare,
        "]":.rightSquare,
        "<|":.leftFuncApp,
        "|>":.rightFuncApp,
        ".":.dot,
        ",":.comma,
        "|":.bar,
        "||":.barbar,
        "&&":.ampersandampersand,
        "not":.not
    ]
    
    static let reserved : [String: TokenType] = [
        "if":.IF,
        "then":.THEN,
        "else":.ELSE,
        "case":.CASE,
        "of":.OF,
        "let":.LET,
        "in":.IN,
        "type":.TYPE,
        "alias":.ALIAS,
    ]
}
