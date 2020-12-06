//
//  Parser.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol ASTNode : CustomStringConvertible {}
protocol Literal : ASTNode {}

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
    
    func parse() throws -> ASTNode {
        // generic parsing logic for the REPL that can parse declerations AND expressions
        if token.type == .identifier {
            return try functionDeclaration()
        }
        return try additiveExpression()
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
        let type: BinaryOpType;

        enum BinaryOpType : String {
            case add = "+", subtract = "-", multiply = "*", divide = "/"
        }
        
        init(_ leftOperand : ASTNode, _ rightOperand : ASTNode, _ type: BinaryOpType) {
            self.leftOperand = leftOperand
            self.rightOperand = rightOperand
            self.type = type
        }

        var description : String {
            return "(\(leftOperand)\(self.type.rawValue)\(rightOperand))"
        }
    }


    
    
    class FloatingPoint : Literal {
        let value : Float

        init(_ value : Float) {
          self.value = value
        }

        var description : String {
            return "\(value)"
        }
    }
    
    class Integer : Literal {
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
              result = BinaryOp(result, try multiplicativeExpression(), .add)
            case .minus:
              advance()
              result = BinaryOp(result, try multiplicativeExpression(), .subtract)
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
                result = BinaryOp(result, try unaryExpression(), .multiply)
            case .forwardSlash:
              advance()
                result = BinaryOp(result, try unaryExpression(), .divide)
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
        case .minus: fallthrough // unary minus
        case .number:
            result = try number()
          default:
            throw ParserError.UnexpectedToken
        }
        return result
      }
    
    func number() throws -> ASTNode {
        assert(token.type == .number || token.type == .minus)
        let result : ASTNode
        var minus = false;
        if token.type == .minus {
            minus = true;
            advance()
        }
        if token.type != .number {
            throw ParserError.UnexpectedToken
        }
        var numberRaw = token.raw;
        if minus {
            numberRaw = "-" + numberRaw;
        }
        if numberRaw.contains(".") {
            result = FloatingPoint(Float(numberRaw)!)
        } else {
            result = Integer(Int(numberRaw)!)
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




