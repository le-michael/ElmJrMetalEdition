//
//  Lexer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import Foundation

enum LexerError : Error {
  case UnexpectedCharacter(_ c : Character)
}

enum Token {
 case LEFT_PARAN, RIGHT_PARAN, PLUS, MINUS, ASTERISK, CARET, FORWARD_SLASH, END_OF_FILE
 case Identifier(String)
 case Number(String)
}


func source() -> String {
  // read all lines of STDIN into a string
  var text =  "";
  while let line = readLine() {
    text += line
  }
  return text
}

func tokenize(text: String) -> [Token] {
  //print("my text: \(text)")
  assert(text.count > 0)
  //let chars = [UInt8](text.utf8)
  let chars = Array(text)
  //print(chars)
  var next_char_index = 0
  var c = chars[next_char_index]

  var tokens = [Token]() 
  func eat() {
    // "eats" a character
    next_char_index += 1
    if next_char_index < chars.count {
      c = chars[next_char_index]
    }
  }

  func is_done() -> Bool {
    return next_char_index >= chars.count
  }

  func eat_whitespace() {
    while c.isWhitespace && !is_done() {
      eat()
    }
  }

  func is_alphabet(_ c : Character) -> Bool {
    return (c >= "A" && c <= "Z") || (c >= "a" && c <= "z")
  }

  func is_digit(_ c : Character) -> Bool {
    return (c >= "0" && c <= "9")
  }

  func get_token() throws -> Token {
    var result : Token?
    switch c {
      case "(":
        result = Token.LEFT_PARAN
      case ")":
        result = Token.RIGHT_PARAN
      case "+":
        result = Token.PLUS
      case "-":
        result = Token.MINUS
      case "*":
        result = Token.ASTERISK
      case "^":
        result = Token.CARET
      case "/":
        result = Token.FORWARD_SLASH
      default:
        result = nil
    }
    if result == nil {
      // token is multiple characters
      if is_alphabet(c) {
        var x : String = "" 
        while is_alphabet(c) && !is_done() {
          x += String(c)
          eat()
        }
        result = Token.Identifier(x)
      } else if is_digit(c) {
        var x : Int = 0
        while is_digit(c) && !is_done() {
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
    eat_whitespace()
    return result!
  }
  
  // eat whitespace at start of file
  eat_whitespace()

  while !is_done() {
    try! tokens.append(get_token())
  }
  tokens.append(Token.END_OF_FILE);

  return tokens
}
