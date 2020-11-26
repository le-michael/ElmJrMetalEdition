//
//  Lexer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//


import Foundation

class Lexer {
    var characters : [Character];
    var characterIndex : Int;
    init(text: String) {
        self.characters = Array(text);
        self.characterIndex = 0;
    }
    
    enum LexerError : Error, Equatable {
        case UnexpectedCharacter(_ c : Character)
        case InvalidNumber
    }
    
    func advance(_ x : Int) {
      characterIndex += x
    }
    
    func ignoreWhitespace() {
        while true {
            if self.characterIndex == self.characters.count { return }
            if !self.characters[self.characterIndex].isWhitespace { return }
            advance(1);
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
    
    func nextToken() throws -> Token {
        ignoreWhitespace()
        if characterIndex == characters.count { return Token(type:.endOfFile, raw:"") }
        var result: Token? = nil
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
