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

class IntegerConstant : ASTNode		 {
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

func parse(text: String) throws -> ASTNode {
    let lexer = Lexer(text: text)
    var token = try! lexer.nextToken()
    func advance() {
        token = try! lexer.nextToken()
    }

    func isDone() -> Bool {
        return token.type != .endOfFile
    }

  func additiveExpression() throws -> ASTNode {
    var result = try multiplicativeExpression()
    while true {
        switch token.type {
        case .plus:
          advance()
          result = BinaryOpAdd(result, try multiplicativeExpression())
        case .minus: 
          advance()
          result = BinaryOpSubtract(result, try multiplicativeExpression())
        default:
          return result
      }
    }
  }

  func multiplicativeExpression() throws -> ASTNode {
    var result = try unaryExpression()
    while true {
        switch token.type {
        case .asterisk:
          advance()
          result = BinaryOpMultiply(result, try unaryExpression())
        case .forwardSlash: 
          advance()
          result = BinaryOpDivide(result, try unaryExpression())
        default:
          return result
      }
    }
  }

  func unaryExpression() throws -> ASTNode {
    let result : ASTNode
    switch token.type {
      case .leftParan:
        advance()
        result = try additiveExpression()
        guard case .rightParan = token.type else {
            throw ParserError.MissingRightParantheses
        }
        advance()
      case .identifier:
        result = Variable(token.raw)
        advance()
    case .number:
        // for now we assume is an int
        advance()
        result = IntegerConstant(Int(token.raw)!)
      default:
        throw ParserError.UnexpectedToken
    }
    return result
  }

  return try additiveExpression()
}




