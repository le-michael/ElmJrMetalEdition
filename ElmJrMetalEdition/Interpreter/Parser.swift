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
        //let opSymbol : String;

        init(_ leftOperand : ASTNode, _ rightOperand : ASTNode) {
            //self.opSymbol = opSymbol
            self.leftOperand = leftOperand
            self.rightOperand = rightOperand
      }

        var description : String {
            var opSymbol : String
            switch self {
                case _ as BinaryOpAdd: opSymbol = "+"
                case _ as BinaryOpMultiply: opSymbol = "*"
                case _ as BinaryOpSubtract: opSymbol = "-"
                case _ as BinaryOpDivide: opSymbol = "/"
            default: opSymbol="ERROR"; assert(false) // Don't want to make this a real exception
            }
            return "(\(leftOperand)\(opSymbol)\(rightOperand))"
      }
    }

    class BinaryOpAdd : BinaryOp { }
    class BinaryOpMultiply : BinaryOp {}
    class BinaryOpSubtract : BinaryOp {}
    class BinaryOpDivide : BinaryOp {}

    class FloatingPoint : ASTNode {
        let value : Float

        init(_ value : Float) {
          self.value = value
        }

        var description : String {
            return "\(value)"
        }
    }
    
    class Integer : ASTNode {
      let value : Int

      init(_ value : Int) {
        self.value = value
      }

        var description : String {
          return "\(value)"
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
                    return "\(name)"
              } else {
                var result = "\(name)"
                for argument in arguments {
                    result += " \(argument)"
                }
                return "(\(result))"
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
            var result = "\(name)"
            for parameter in parameters {
                result += " \(parameter)"
            }
            result += " = \(body)"
            return result
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
            result = try number()
          default:
            throw ParserError.UnexpectedToken
        }
        return result
      }
    
    func number() throws -> ASTNode {
        assert(token.type == .number)
        let result : ASTNode
        if token.raw.contains(".") {
            result = FloatingPoint(Float(token.raw)!)
        } else {
            result = Integer(Int(token.raw)!)
        }
        advance()
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




