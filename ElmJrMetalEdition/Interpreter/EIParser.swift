//
//  Parser.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol EINode : CustomStringConvertible {}
protocol EILiteral : EINode {}

class EIParser {
    let lexer : EILexer
    var token : Token
    
    func advance() {
        token = try! lexer.nextToken()
    }
    
    init(text : String) {
        lexer = EILexer(text: text)
        token = try! lexer.nextToken()
    }

    func isDone() -> Bool {
        return token.type == .endOfFile
    }
    
    func parse() throws -> EINode {
        // TODO: This check is incorrect. An expression can also start with an identifier.
        // generic parsing logic for the REPL that can parse declarations AND expressions
        if token.type == .identifier {
            return try functionDeclaration()
        }
        return try additiveExpression()
    }
    
    func parseExpression() throws -> EINode {
        return try additiveExpression()
    }
    
    func parseDeclaration() throws -> Function {
        return try functionDeclaration()
    }
    
    enum ParserError : Error {
      case MissingRightParantheses
      case UnexpectedToken
      case NotImplemented
    }
    
    class BinaryOp : EINode {
        let leftOperand : EINode;
        let rightOperand : EINode;
        let type: BinaryOpType;

        enum BinaryOpType : String {
            case add = "+", subtract = "-", multiply = "*", divide = "/"
        }
        
        init(_ leftOperand : EINode, _ rightOperand : EINode, _ type: BinaryOpType) {
            self.leftOperand = leftOperand
            self.rightOperand = rightOperand
            self.type = type
        }

        var description : String {
            return "(\(leftOperand)\(self.type.rawValue)\(rightOperand))"
        }
    }


    
    
    class FloatingPoint : EILiteral {
        let value : Float

        init(_ value : Float) {
          self.value = value
        }

        var description : String {
            return "\(value)"
        }
    }
    
    class Integer : EILiteral {
      let value : Int

      init(_ value : Int) {
        self.value = value
      }

        var description : String {
          return "\(value)"
        }
    }

    class Boolean : EILiteral {
        let value : Bool
        
        init(_ value : Bool) {
          self.value = value
        }
        
        var description : String {
            return value ? "True": "False"
        }
    }
    
    class IfElse : EINode {
        let conditions : [EINode]
        let branches : [EINode]
        
        init(conditions: [EINode], branches: [EINode]) {
            self.conditions = conditions
            self.branches = branches
        }
        
        var description: String {
            assert(branches.count == conditions.count + 1)
            var index = 0
            var result = ""
            while index < conditions.count {
                result += "if \(conditions[index]) then \(branches[index]) else "
                index += 1;
            }
            result += "\(branches[index])"
            return result
        }
    }
    
    class FunctionCall : EINode {
        var name : String
        var arguments : [EINode]

        init(name : String, arguments : [EINode]) {
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
    
    class Function : EINode {
        let name : String
        let parameters : [String]
        let body : EINode
        
        init(name : String, parameters : [String], body: EINode) {
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

    func functionDeclaration() throws -> Function {
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
    
    func additiveExpression() throws -> EINode {
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

      func multiplicativeExpression() throws -> EINode {
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

      func unaryExpression() throws -> EINode {
        let result : EINode
        switch token.type {
          case .leftParan:
            advance()
            result = try additiveExpression()
            guard case .rightParan = token.type else {
                throw ParserError.MissingRightParantheses
            }
            advance()
          case .identifier:
            if tokenIsType() {
                result = try TypeExpression()
            } else {
                result = try parseFunctionCall()
            }
        case .IF:
            result = try IfExpression()
        case .minus: fallthrough // unary minus
        case .number:
            result = try number()
          default:
            throw ParserError.UnexpectedToken
        }
        return result
      }
    
    func TypeExpression() throws -> EINode {
        switch token.raw {
        case "True":
            advance()
            return Boolean(true)
        case "False":
            advance()
            return Boolean(false)
        default:
            // we don't support custom types yet
            throw ParserError.NotImplemented
        }
    }
    
    func tokenIsType() -> Bool {
        if token.type != .identifier { return false }
        assert(token.raw.count >= 1)
        let first = token.raw.first
        return first!.isUppercase
    }
    
    func IfExpression() throws -> EINode {
        assert(token.type == .IF)
        var conditions = [EINode]()
        var branches = [EINode]()
        while (token.type == .IF) {
            advance()
            try conditions.append(additiveExpression())
            assert(token.type == .THEN)
            advance()
            try branches.append(additiveExpression())
            assert(token.type == .ELSE)
            advance()
        }
        try branches.append(additiveExpression())
        return IfElse(conditions: conditions, branches: branches)
    }
    
    func number() throws -> EINode {
        assert(token.type == .number || token.type == .minus)
        let result : EINode
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
    
    func parseFunctionCall() throws -> EINode {
        let name = token.raw
        var arguments = [EINode]()
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




