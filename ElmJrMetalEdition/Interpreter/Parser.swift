//
//  Parser.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol ASTNode : CustomStringConvertible {
}

class Parser {
    let lexer : Lexer
    var token : Token
    
    func advance() {
        token = try! lexer.nextToken()
    }
    
    init(text : String) {
        lexer = Lexer(text: text)
        token = try! lexer.nextToken()
    }

    func isDone() -> Bool {
        return token.type != .endOfFile
    }
    
    func parseExpression() throws -> ASTNode {
        return try additiveExpression()
    }
    
    func parseDeclaration() throws -> ASTNode {
        return try functionDeclaration()
    }
    
    enum ParserError : Error {
      case MissingRightParantheses
      case UnexpectedToken
      case NotImplemented
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

    class Integer : ASTNode         {
      let value : Int

      init(_ value : Int) {
        self.value = value
      }

        var description : String {
          return "Integer(\(value))"
        }
    }

    class FunctionCall : ASTNode {
        var name : String
        var arguments : [ASTNode]

        init(name : String, arguments : [ASTNode]) {
            self.name = name
            self.arguments = arguments
        }

      var description : String {
        if arguments.count == 0 {
            return "FunctionCall(\"\(name)\")"
        } else {
            return "FunctionCall(\"\(name),\(arguments)\")"
        }
      }
    }
    
    class Function : ASTNode {
        let name : String
        let parameters : [String]
        let body : ASTNode
        
        init(name : String, parameters : [String], body: ASTNode) {
            self.name = name
            self.parameters = parameters
            self.body = body
        }

        var description : String {
          return "\(name)(\(parameters)){\(body)}"
        }
    }

    func functionDeclaration() throws -> ASTNode {
        assert(token.type == .identifier)
        let name = token.raw
        advance()
        var parameters = [String]()
        // for now we assume parameters are strings rather than patterns
        while token.type == .identifier {
            parameters.append(token.raw)
            advance()
        }
        assert(token.type == .equal)
        advance()
        let body = try additiveExpression()
        return Function(name: name, parameters: parameters, body: body)
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
            result = try parseFunctionCall()
        case .number:
            // for now we assume is an int
            result = Integer(Int(token.raw)!)
            advance()
          default:
            throw ParserError.UnexpectedToken
        }
        return result
      }
    
    func parseFunctionCall() throws -> ASTNode {
        let name = token.raw
        var arguments = [ASTNode]()
        advance()
        var flag = false
        // read arguments until we counter something that can't be an argument
        while !flag {
            if token.type == .identifier {
                // here we are either passing a variable value or a function
                arguments.append(FunctionCall(name: token.raw, arguments:[]))
                advance()
                continue;
            }
            switch token.type {
            case .leftParan: fallthrough
            case .identifier: fallthrough
            case .number:
                arguments.append(try additiveExpression())
            default:
                flag = true
            }
        }
        return FunctionCall(name: name, arguments: arguments)
    }

}




