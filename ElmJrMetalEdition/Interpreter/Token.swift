//
//  Token.swift
//  ElmJrMetalEdition
//
//  Created by user186747 on 11/23/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

struct Token {
    var type: TokenType;
    var raw: String;
    
    enum TokenType {
        case leftParan, rightParan, plus, plusplus, minus, asterisk, caret, forwardSlash, singlequote, doublequote, endOfFile, equal, equalequal, True, False
        case identifier
        case number
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
    ]
    
    static let reserved : [String: TokenType] = [
        "True":.True,
        "False":.False,
    ]
}
