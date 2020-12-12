//
//  Lexer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//


import Foundation

class EILexer {
    var characters : [Character];
    var characterIndex : Int;
    init(text: String) {
        self.characters = Array(text);
        self.characterIndex = 0;
    }
    
    enum LexerError : Error, Equatable {
        case UnexpectedCharacter(_ c : Character)
        case InvalidNumber
        case StringMissingEndQuote
        case CharMissingEndQuote
        case CharMustHaveLengthOne
    }
    
    func advance(_ x : Int) {
      characterIndex += x
    }
    
    func ignoreWhitespace() {
        while true {
            if characterIndex == characters.count { return }
            if !characters[characterIndex].isWhitespace { return }
            advance(1);
        }
    }
    
    func handleBlockComment() {
        assert(prefixMatches("{-"))
        var stk = 1
        advance(2)
        while true {
            while characterIndex + 1 < characters.count &&
                    !prefixMatches("{-") && !prefixMatches("-}") {
                advance(1)
            }
            if characterIndex + 1 >= characters.count {
                characterIndex = characters.count
                return
            }
            if prefixMatches("{-") {
                stk += 1
                advance(2)
            }
            else if prefixMatches("-}") {
                stk -= 1
                advance(2)
                if stk == 0 {
                    return
                }
            }
        }
    }
    
    func ignoreCommentsAndWhitespace() {
        ignoreWhitespace()
        while characterIndex + 1 < characters.count {
            if prefixMatches("--") {
                while characterIndex < characters.count && characters[characterIndex] != "\n" {
                    advance(1)
                }
                ignoreWhitespace()
            } else if prefixMatches("{-") {
                handleBlockComment()
                ignoreWhitespace()
                break;
            } else {
                // no comments!
                break;
            }
        }
    }
    
    func prefixMatches(_ s: String) -> Bool {
        if s.count > characters.count - characterIndex {
            return false
        }
        let schars = Array(s)
        for i in 0..<s.count {
            if schars[i] != characters[characterIndex + i] {
                return false
            }
        }
        return true
    }
    
    func matchSymbol() -> Token? {
        var result: Token? = nil
        for (raw, type) in Token.symbols {
            if prefixMatches(raw) && (result == nil || result!.raw.count < raw.count) {
                result = Token(type:type, raw:raw)
            }
        }
        if result != nil { advance(result!.raw.count) }
        return result
    }
    
    func isAlphabet(_ c : Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
    }
    
    func isDigit(_ c : Character) -> Bool {
        return (c >= "0" && c <= "9")
    }
    
    func matchIdentifier() -> Token? {
        var c : Character = characters[characterIndex]
        if !isAlphabet(c) { return nil }
        var string : String = ""
        while isAlphabet(c) || isDigit(c) || c == "_" {
            string += String(c)
            advance(1)
            if characterIndex == characters.count { break }
            c = characters[characterIndex]
        }
        if let token = Token.reserved[string] {
            return Token(type: token, raw:string)
        }
        return Token(type:.identifier, raw:string)
    }
    
    func matchNumber() throws -> Token? {
        var c : Character = characters[characterIndex]
        if !isDigit(c) { return nil }
        var string = ""
        var seenDecimal = false
        while isDigit(c) || c == "." {
            if c == "." {
                if seenDecimal {
                    throw LexerError.InvalidNumber
                }
                seenDecimal = true
            }
            string += String(c)
            advance(1)
            if characterIndex == characters.count { break }
            c = characters[characterIndex]
        }
        if characterIndex != characters.count && (isAlphabet(c) || c == "_") {
            throw LexerError.UnexpectedCharacter(c)
        }
        return Token(type:.number, raw:string)
    }
    
    func matchStringOrChar() throws -> Token? {
        var c : Character = characters[characterIndex]
        let singleQuote: Character = "'";
        let doubleQuote: Character = "\"";
        var raw = "";
        for quote in [singleQuote, doubleQuote] {
            if c == quote {
                advance(1);
                if characterIndex == characters.count {
                    throw LexerError.StringMissingEndQuote
                }
                c = characters[characterIndex]
                while c != quote {
                    raw += String(c);
                    advance(1);
                    if characterIndex == characters.count {
                        throw LexerError.StringMissingEndQuote
                    }
                    c = characters[characterIndex]
                }
                advance(1)
                if quote == singleQuote {
                    if raw.count > 1 {
                        throw LexerError.CharMustHaveLengthOne
                    }
                    return Token(type:.char, raw:raw)
                } else {
                    return Token(type:.string, raw:raw)
                }
            }
        }
        return nil
    }
    
    func nextToken() throws -> Token {
        ignoreCommentsAndWhitespace()
        if characterIndex == characters.count { return Token(type:.endOfFile, raw:"") }
        var result: Token? = nil
        // "string" or character 'c'
        result = try matchStringOrChar()
        if result != nil { return result! }
        // symbol + - ++
        result = matchSymbol()
        if result != nil { return result! }
        // identifier (includes reserved words)
        result = matchIdentifier()
        if result != nil { return result! }
        // number
        result = try matchNumber()
        if result != nil { return result! }
        // couldn't match with anything
        throw LexerError.UnexpectedCharacter(characters[characterIndex])
    }
}
