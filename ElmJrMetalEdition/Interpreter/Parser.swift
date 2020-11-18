//
//  Parser.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

enum ParserError : Error {
  case MissingRightParantheses
  case UnexpectedToken
}

protocol ASTNode : CustomStringConvertible {
}

class BinaryOp : ASTNode {
  let leftOperand : ASTNode;
  let rightOperand : ASTNode;

  init(_ leftOperand : ASTNode, _ rightOperand : ASTNode) {
    self.leftOperand = leftOperand
    self.rightOperand = rightOperand
  }

  var description : String {
    return "\(String(describing:type(of:self)))(\(leftOperand),\(rightOperand))"
  }
}

class BinaryOpAdd : BinaryOp {}
class BinaryOpMultiply : BinaryOp {}
class BinaryOpSubtract : BinaryOp {}
class BinaryOpDivide : BinaryOp {}

class IntegerConstant : ASTNode {
  let value : Int

  init(_ value : Int) {
    self.value = value
  }

  var description : String {
    return "IntegerConstant(\(value))"
  }
}

class Variable : ASTNode {
  var name : String

  init(_ name : String) {
    self.name = name
  }

  var description : String {
    return "Variable(\"\(name)\")"
  }
}



func parse(_ tokens:[Token]) throws -> ASTNode {
  //print(tokens)
  var next_token_index = 0
  var c = tokens[next_token_index]

  func eat() {
    if next_token_index < tokens.count {
      next_token_index += 1
      c = tokens[next_token_index]
    }
  }

  func is_done() -> Bool {
    return next_token_index >= tokens.count
  }

  func additive_expression() throws -> ASTNode {
    var result = try multiplicative_expression()
    while true {
      switch c {
        case .PLUS:
          eat()  
          result = BinaryOpAdd(result, try multiplicative_expression())
        case .MINUS: 
          eat()  
          result = BinaryOpSubtract(result, try multiplicative_expression())
        default:
          return result
      }
    }
  }

  func multiplicative_expression() throws -> ASTNode {
    var result = try unary_expression()
    while true {
      switch c {
        case .ASTERISK:
          eat()  
          result = BinaryOpMultiply(result, try unary_expression())
        case .FORWARD_SLASH: 
          eat()  
          result = BinaryOpDivide(result, try unary_expression())
        default:
          return result
      }
    }
  }

  func unary_expression() throws -> ASTNode {
    let result : ASTNode
    switch c {
      case .LEFT_PARAN:
        eat()
        result = try additive_expression()
        guard case .RIGHT_PARAN = c else {
            throw ParserError.MissingRightParantheses
        }
        eat()
      case .Identifier(let name):
        result = Variable(name)
        eat()
      case .Number(let number):
        // for now we assume is an int
        eat()
        result = IntegerConstant(Int(number)!)
      default:
        throw ParserError.UnexpectedToken
    }
    return result
  }

  return try additive_expression()
}

func parser_test() {
  let tests = [
    "foo",
    "(bar)",
    "(((moo)))",
    "x*y",
    "x*(y*z)",
    "a + b*c + d*(e + f + g)",
    "a + 1",
    "(2 + y * 5 + 123) * (4/fooBar - 2)",
  ]

  for test in tests {
    print(try! parse(tokenize(text: test)))
  }
}



