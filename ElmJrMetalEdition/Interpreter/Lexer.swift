//
//  Lexer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//


import Foundation

enum LexerError : Error {
  case UnexpectedCharacter(_ c : Character)
}

enum Token {
 case leftParan, rightParan, plus, minus, asterisk, caret, forwardSlash, endOfFile
 case Identifier(String)
 case Number(String)
}


func source() -> String {
  var text =  "";
  while let line = readLine() {
    text += line
  }
  return text
}

func tokenize(text: String) -> [Token] {
  assert(text.count > 0)
  let chars = Array(text)
  var nextCharIndex = 0
  var c = chars[nextCharIndex]

  var tokens = [Token]() 
  func eat() {
    nextCharIndex += 1
    if nextCharIndex < chars.count {
      c = chars[nextCharIndex]
    }
  }

  func isDone() -> Bool {
    return nextCharIndex >= chars.count
  }

  func eatWhitespace() {
    while c.isWhitespace && !isDone() {
      eat()
    }
  }

  func isAlphabet(_ c : Character) -> Bool {
    return (c >= "A" && c <= "Z") || (c >= "a" && c <= "z")
  }

  func isDigit(_ c : Character) -> Bool {
    return (c >= "0" && c <= "9")
  }

  func getToken() throws -> Token {
    var result : Token?
    switch c {
      case "(":
        result = Token.leftParan
      case ")":
        result = Token.rightParan
      case "+":
        result = Token.plus
      case "-":
        result = Token.minus
      case "*":
        result = Token.asterisk
      case "^":
        result = Token.caret
      case "/":
        result = Token.forwardSlash
      default:
        result = nil
    }
    if result == nil {
      // token is multiple characters
      if isAlphabet(c) {
        var x : String = "" 
        while isAlphabet(c) && !isDone() {
          x += String(c)
          eat()
        }
        result = Token.Identifier(x)
      } else if isDigit(c) {
        var x : Int = 0
        while isDigit(c) && !isDone() {
          x *= 10
          x += c.wholeNumberValue! - 0
          eat()
        }
        result = Token.Number(String(x))
      } else {
        throw LexerError.UnexpectedCharacter(c)
      }
    } else {
      // token was a single character
      eat()
    }
    eatWhitespace()
    return result!
  }
  
  // eat whitespace at start of file
  eatWhitespace()

  while !isDone() {
    try! tokens.append(getToken())
  }
  tokens.append(Token.endOfFile);

  return tokens
}
