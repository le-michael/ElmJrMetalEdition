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
  var nextTokenIndex = 0
  var c = tokens[nextTokenIndex]

  func eat() {
    if nextTokenIndex < tokens.count {
      nextTokenIndex += 1
      c = tokens[nextTokenIndex]
    }
  }

  func isDone() -> Bool {
    return nextTokenIndex >= tokens.count
  }

  func additiveExpression() throws -> ASTNode {
    var result = try multiplicativeExpression()
    while true {
      switch c {
        case .plus:
          eat()  
          result = BinaryOpAdd(result, try multiplicativeExpression())
        case .minus: 
          eat()  
          result = BinaryOpSubtract(result, try multiplicativeExpression())
        default:
          return result
      }
    }
  }

  func multiplicativeExpression() throws -> ASTNode {
    var result = try unaryExpression()
    while true {
      switch c {
        case .asterisk:
          eat()  
          result = BinaryOpMultiply(result, try unaryExpression())
        case .forwardSlash: 
          eat()  
          result = BinaryOpDivide(result, try unaryExpression())
        default:
          return result
      }
    }
  }

  func unaryExpression() throws -> ASTNode {
    let result : ASTNode
    switch c {
      case .leftParan:
        eat()
        result = try additiveExpression()
        guard case .rightParan = c else {
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

  return try additiveExpression()
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



