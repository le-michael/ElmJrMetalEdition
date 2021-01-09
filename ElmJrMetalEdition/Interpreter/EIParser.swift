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
    var token : EIToken
    
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
            return try declaration()
        }
        return try additiveExpression()
    }
    
    func parseExpression() throws -> EINode {
        return try andableExpression()
    }
    
    func parseDeclaration() throws -> Declaration {
        return try declaration()
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
            case eq = "==", ne = "/=", le = "<=", ge = ">=", lt = "<", gt = ">"
            case and = "&&", or = "||"
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
    
    class UnaryOp : EINode {
        let operand : EINode
        let type: UnaryOpType
        
        enum UnaryOpType : String {
            case not = "not"
        }
        
        init(operand: EINode, type: UnaryOpType) {
            self.operand = operand
            self.type = type
        }
        
        var description: String {
            return "(\(self.type.rawValue) \(operand))"
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
    
    class FunctionApplication : EINode {
        var function : EINode
        var argument : EINode
        
        init(function: EINode, argument: EINode) {
            self.function = function
            self.argument = argument
        }
        var description : String {
            return "(\(function) \(argument))"
        }
    }
    
    class Variable : EINode {
        let name : String
        
        init(name: String) {
            self.name = name
        }
        
        var description: String {
            return name
        }
    }
    
    class Function : EINode {
        let parameter : String // Will be replaced by a pattern later
        let body : EINode
        
        init(parameter : String, body : EINode) {
            self.parameter = parameter
            self.body = body
        }

        var description : String {
            // display as anonymous function
            return "(\\\(parameter) -> \(body))"
        }
    }
    
    class Declaration : EINode {
        let name : String
        let body : EINode
        
        init(name: String, body: EINode) {
            self.name = name
            self.body = body
        }
        
        var description: String {
            return "\(name) = \(body)"
        }
    }

    func declaration() throws -> Declaration {
        assert(token.type == .identifier)
        let name = token.raw
        advance()
        // for now we assume parameters are strings rather than patterns
        var parameters = [String]()
        while token.type == .identifier {
            parameters.append(token.raw)
            advance()
        }
        assert(token.type == .equal)
        advance()
        var node = try andableExpression()
        for parameter in parameters.reversed() {
            node = Function(parameter: parameter, body: node)
        }
        return Declaration(name: name, body: node)
    }
    
    func andableExpression() throws -> EINode {
        var result = try equatableExpression()
        while true {
            switch token.type {
            case .ampersandampersand:
                advance()
                result = BinaryOp(result, try equatableExpression(), .and)
            case .barbar:
                advance()
                result = BinaryOp(result, try equatableExpression(), .or)
            default:
                return result
            }
        }
    }
    
    func equatableExpression() throws -> EINode {
        if token.type == .not {
            advance()
            return UnaryOp(operand: try equatableExpression(), type: .not)
        }
        var result = try additiveExpression()
        while true {
            switch token.type {
            case .equalequal:
                advance()
                result = BinaryOp(result, try additiveExpression(), .eq)
            case .notequal:
                advance()
                result = BinaryOp(result, try additiveExpression(), .ne)
            case .lessequal:
                advance()
                result = BinaryOp(result, try additiveExpression(), .le)
            case .greaterequal:
                advance()
                result = BinaryOp(result, try additiveExpression(), .ge)
            case .lessthan:
                advance()
                result = BinaryOp(result, try additiveExpression(), .lt)
            case .greaterthan:
                advance()
                result = BinaryOp(result, try additiveExpression(), .gt)
            default:
                return result
            }
        }
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
        var result = try funcativeExpression()
        while true {
            switch token.type {
            case .asterisk:
              advance()
                result = BinaryOp(result, try funcativeExpression(), .multiply)
            case .forwardSlash:
              advance()
                result = BinaryOp(result, try funcativeExpression(), .divide)
            default:
              return result
          }
        }
      }
    
    func funcativeExpression() throws -> EINode {
        while token.type == .newline { advance() }
        var result = try unaryExpression()
        while tokenCouldStartExpression() {
            result = FunctionApplication(function: result, argument: try unaryExpression())
        }
        while token.type == .newline { advance() }
        return result
    }

    func tokenCouldStartExpression() -> Bool {
        return token.type == .leftParan || token.type == .identifier || token.type == .number || token.type == .string
    }

      func unaryExpression() throws -> EINode {
        let result : EINode
        switch token.type {
          case .leftParan:
            advance()
            result = try andableExpression()
            guard case .rightParan = token.type else {
                throw ParserError.MissingRightParantheses
            }
            advance()
          case .identifier:
            if tokenIsType() {
                result = try typeExpression()
            } else {
                result = try variable()
            }
        case .IF:
            result = try ifExpression()
        case .minus: fallthrough // unary minus
        case .number:
            result = try number()
          default:
            throw ParserError.UnexpectedToken
        }
        return result
      }
    
    func variable() throws -> EINode {
        assert(token.type == .identifier)
        let name = token.raw
        advance()
        return Variable(name: name)
    }
    
    func typeExpression() throws -> EINode {
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
    
    func ifExpression() throws -> EINode {
        assert(token.type == .IF)
        var conditions = [EINode]()
        var branches = [EINode]()
        while (token.type == .IF) {
            advance()
            try conditions.append(andableExpression())
            assert(token.type == .THEN)
            advance()
            try branches.append(andableExpression())
            assert(token.type == .ELSE)
            advance()
        }
        try branches.append(andableExpression())
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

}




