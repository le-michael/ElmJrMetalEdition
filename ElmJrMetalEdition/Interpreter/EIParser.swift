//
//  Parser.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol EINode: CustomStringConvertible {}
protocol EILiteral: EINode {}

class EIParser {
    let lexer: EILexer
    var token: EIToken
    var types: [String:MonoType]
    
    let builtinTypes = [
        "Int": MonoType.TCon("Int"),
        "Float": MonoType.TCon("Float"),
        "List": MonoType.CustomType("List", [MonoType.TVar("a")])
    ]
        
    init(text: String = "") {
        lexer = EILexer(text: text)
        token = try! lexer.nextToken()
        // builtins
        types = builtinTypes
    }
    
    func advance() {
        token = try! lexer.nextToken()
    }
    
    func appendText(text: String) throws {
        lexer.appendText(text: text)
        if token.type == .endOfFile {
            token = try lexer.nextToken()
        }
    }

    func isDone() -> Bool {
        return token.type == .endOfFile
    }
    
    func parse() throws -> EINode {
        // TODO: This check is incorrect. An expression can also start with an identifier.
        // generic parsing logic for the REPL that can parse declarations AND expressions
        if token.type == .identifier || token.type == .TYPE {
            return try parseDeclaration()
        }
        return try parseExpression()
    }
    
    func parseExpression() throws -> EINode {
        return try andableExpression()
    }
    
    func parseDeclaration() throws -> EINode {
        if token.type == .TYPE {
            return try typeDeclaration()
        }
        return try declaration()
    }
    
    enum ParserError: Error {
        case MissingRightParantheses
        case UnexpectedToken
        case NotImplemented
        case TypeIsNotKnown
        case MaxTupleSizeIsThree
    }
    
    func typeDeclaration() throws -> EINode {
        assert(token.type == .TYPE)
        advance()
        assert(token.type == .identifier)
        assert(tokenIsCapitalizedIdentifier())
        let name = token.raw
        advance()
        var typeVars = [String]()
        while token.type == .identifier {
            typeVars.append(token.raw)
            advance()
        }
        // we immediately put type name in type lookup
        // because we might have a recursive type
        types[name] = MonoType.CustomType(name, typeVars.map{MonoType.TVar($0)})
        assert(token.type == .equal)
        advance()
        var typeConstructors = [EIAST.ConstructorDefinition]()
        while(true) {
            typeConstructors.append(try typeConstructor(typeVars: typeVars))
            while token.type == .newline {
                advance()
            }
            if token.type != .bar {
                break
            }
            advance()
        }
        return EIAST.TypeDefinition(typeName: name, typeVars: typeVars, constructors: typeConstructors)
    }
    
    func typeConstructor(typeVars: [String]) throws -> EIAST.ConstructorDefinition {
        assert(token.type == .identifier)
        assert(tokenIsCapitalizedIdentifier())
        let name = token.raw
        advance()
        var typeParameters = [MonoType]()
        while token.type != .newline && token.type != .bar && token.type != .endOfFile {
            typeParameters.append(try type(typeVars: typeVars))
        }
        return EIAST.ConstructorDefinition(constructorName: name, typeParameters: typeParameters)
    }
    
    /*
     For parsing a type. 'bounded' here means that we are parsing a section immediately surrounded by parantheses or commas.
     */
    func type(typeVars: [String], bounded: Bool = false) throws -> MonoType {
        switch token.type {
        case .identifier:
            if tokenIsCapitalizedIdentifier() {
                if types[token.raw] != nil {
                    // must have no arguments
                    let t = types[token.raw]
                    advance()
                    switch t {
                    case .CustomType(let name, let parameterVars):
                        if !bounded {
                            // TODO: replace this with a proper error
                            assert(parameterVars.count == 0)
                        }
                        var parameters = [MonoType]()
                        for _ in 0..<parameterVars.count {
                            parameters.append(try type(typeVars: typeVars))
                        }
                        return MonoType.CustomType(name, parameters)
                    default:
                        return t!
                    }
                } else {
                    throw ParserError.TypeIsNotKnown
                }
            } else {
                // token is a type var
                if typeVars.contains(token.raw) {
                    let result = MonoType.TVar(token.raw)
                    advance()
                    return result
                }
                throw ParserError.UnexpectedToken
            }
        case .leftParan:
            advance()
            defer { assert(token.type == .rightParan); advance() } // for right parantheses
            let t1 = try type(typeVars: typeVars, bounded: true)
            if token.type == .rightParan {
                return t1
            }
            assert(token.type == .comma)
            advance()
            let t2 = try type(typeVars: typeVars, bounded: true)
            if token.type == .rightParan {
                return MonoType.TupleType(t1, t2, nil)
            }
            assert(token.type == .comma)
            advance()
            let t3 = try type(typeVars: typeVars, bounded: true)
            if token.type == .rightParan {
                return MonoType.TupleType(t1, t2, t3)
            }
            throw ParserError.MaxTupleSizeIsThree
        default:
            throw ParserError.NotImplemented
        }
    }
    
    func declaration() throws -> EIAST.Declaration {
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
            node = EIAST.Function(parameter: parameter, body: node)
        }
        return EIAST.Declaration(name: name, body: node)
    }
    
    func andableExpression() throws -> EINode {
        var result = try equatableExpression()
        while true {
            switch token.type {
            case .ampersandampersand:
                advance()
                result = EIAST.BinaryOp(result, try equatableExpression(), .and)
            case .barbar:
                advance()
                result = EIAST.BinaryOp(result, try equatableExpression(), .or)
            default:
                return result
            }
        }
    }
    
    func equatableExpression() throws -> EINode {
        if token.type == .not {
            advance()
            return EIAST.UnaryOp(operand: try equatableExpression(), type: .not)
        }
        var result = try additiveExpression()
        while true {
            switch token.type {
            case .equalequal:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .eq)
            case .notequal:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .ne)
            case .lessequal:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .le)
            case .greaterequal:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .ge)
            case .lessthan:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .lt)
            case .greaterthan:
                advance()
                result = EIAST.BinaryOp(result, try additiveExpression(), .gt)
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
                result = EIAST.BinaryOp(result, try multiplicativeExpression(), .add)
            case .minus:
                advance()
                result = EIAST.BinaryOp(result, try multiplicativeExpression(), .subtract)
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
                result = EIAST.BinaryOp(result, try funcativeExpression(), .multiply)
            case .forwardSlash:
                advance()
                result = EIAST.BinaryOp(result, try funcativeExpression(), .divide)
            default:
                return result
            }
        }
    }
    
    func funcativeExpression() throws -> EINode {
        while token.type == .newline { advance() }
        var result = try unaryExpression()
        while tokenCouldStartExpression() {
            result = EIAST.FunctionApplication(function: result, argument: try unaryExpression())
        }
        while token.type == .newline { advance() }
        return result
    }

    func tokenCouldStartExpression() -> Bool {
        return token.type == .leftParan || token.type == .identifier || token.type == .number || token.type == .string
    }

    func unaryExpression() throws -> EINode {
        let result: EINode
        switch token.type {
        case .leftParan:
            advance()
            let v1 = try andableExpression()
            if token.type == .comma {
                advance()
                let v2 = try andableExpression()
                if token.type == .comma {
                    advance()
                    let v3 = try andableExpression()
                    result = EIAST.Tuple(v1,v2,v3)
                } else {
                    result = EIAST.Tuple(v1,v2,nil)
                }
            } else {
                result = v1
            }
            guard case .rightParan = token.type else {
                throw ParserError.MissingRightParantheses
            }
            advance()
        case .leftSquare:
            advance()
            var items = [EINode]()
            while token.type != .rightSquare {
                let expr = try andableExpression()
                items.append(expr)
                if token.type == .comma { advance() }
            }
            advance()
            result = EIAST.List(items)
        case .identifier:
            if tokenIsCapitalizedIdentifier() {
                result = try typeExpression()
            } else {
                result = try variable()
            }
        case .IF:
            result = try ifExpression()
        case .backSlash:
            result = try anonymousFunction()
        case .minus: fallthrough // unary minus
        case .number:
            result = try number()
        default:
            throw ParserError.UnexpectedToken
        }
        return result
    }
    
    func anonymousFunction() throws -> EINode {
        assert(token.type == .backSlash)
        advance()
        assert(token.type == .identifier)
        var parameters = [String]()
        while token.type == .identifier {
            parameters.append(token.raw)
            advance()
        }
        assert(token.type == .arrow)
        advance()
        var node = try andableExpression()
        for parameter in parameters.reversed() {
            node = EIAST.Function(parameter: parameter, body: node)
        }
        return node
    }
    
    func variable() throws -> EINode {
        assert(token.type == .identifier)
        let name = token.raw
        advance()
        return EIAST.Variable(name: name)
    }
    
    func typeExpression() throws -> EINode {
        switch token.raw {
        case "True":
            advance()
            return EIAST.Boolean(true)
        case "False":
            advance()
            return EIAST.Boolean(false)
        default:
            return try variable()
        }
    }
    
    func tokenIsCapitalizedIdentifier() -> Bool {
        if token.type != .identifier { return false }
        assert(token.raw.count >= 1)
        let first = token.raw.first
        return first!.isUppercase
    }
    
    func ifExpression() throws -> EINode {
        assert(token.type == .IF)
        var conditions = [EINode]()
        var branches = [EINode]()
        while token.type == .IF {
            advance()
            try conditions.append(andableExpression())
            assert(token.type == .THEN)
            advance()
            try branches.append(andableExpression())
            assert(token.type == .ELSE)
            advance()
        }
        try branches.append(andableExpression())
        return EIAST.IfElse(conditions: conditions, branches: branches)
    }
    
    func number() throws -> EINode {
        assert(token.type == .number || token.type == .minus)
        let result: EINode
        var minus = false
        if token.type == .minus {
            minus = true
            advance()
        }
        if token.type != .number {
            throw ParserError.UnexpectedToken
        }
        var numberRaw = token.raw
        if minus {
            numberRaw = "-" + numberRaw
        }
        if numberRaw.contains(".") {
            result = EIAST.FloatingPoint(Float(numberRaw)!)
        } else {
            result = EIAST.Integer(Int(numberRaw)!)
        }
        advance()
        return result
    }
}
