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
        "Bool": MonoType.TCon("Bool"),
        "String": MonoType.TCon("String"),
        "List": MonoType.CustomType("List", [MonoType.TVar("a")])
    ]
    
    enum ParserError: Error {
        case MissingRightParantheses
        case UnexpectedToken
        case NotImplemented
        case TypeIsNotKnown
        case MaxTupleSizeIsThree
    }
    
    func safeAssert(_ toAssert: Bool) throws {
        if !toAssert {
            throw ParserError.NotImplemented
        }
    }
        
    init(text: String = "") throws {
        lexer = EILexer(text: text)
        token = try lexer.nextToken()
        // builtins
        types = builtinTypes
    }
    
    func advance() throws {
        token = try lexer.nextToken()
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
        return try funcAppableExpression()
    }
    
    func parseDeclaration() throws -> EINode {
        //defer { try eatNewlines() }
        try eatNewlines()
        if token.type == .MODULE {
            return try moduleDeclaration()
        }
        if token.type == .IMPORT {
            return try importDeclaration()
        }
        if token.type == .TYPE {
            return try typeDeclaration()
        }
        return try declaration()
    }
    
    
    
    func eatNewlines() throws {
        while token.type == .newline {
            try advance()
        }
    }
    
    func moduleDeclaration() throws -> EINode {
        // TODO: Implement module/import system
        try safeAssert(token.type == .MODULE)
        try advance()
        try safeAssert(token.type == .identifier)
        try advance()
        try safeAssert(token.type == .EXPOSING)
        try advance()
        try eatNewlines()
        try safeAssert(token.type == .leftParan)
        try ignore()
        return EIAST.NoValue()
    }
    
    func importDeclaration() throws -> EINode {
        // TODO: Implement module/import system
        try safeAssert(token.type == .IMPORT)
        try advance()
        try safeAssert(token.type == .identifier)
        try advance()
        try safeAssert(token.type == .EXPOSING)
        try advance()
        try eatNewlines()
        try safeAssert(token.type == .leftParan)
        try ignore()
        return EIAST.NoValue()
    }
    
    func ignore() throws {
        // TODO: This code will eventually be removed
        // Currently I have it so I can ignore Module/Import stuff.
        try safeAssert(token.type == .leftParan)
        try advance()
        while token.type != .rightParan {
            if token.type == .leftParan {
                try ignore()
            } else {
                try advance()
            }
        }
        try advance()
    }
    
    
    
    
    func typeDeclaration() throws -> EINode {
        try safeAssert(token.type == .TYPE)
        try advance()
        try safeAssert(token.type == .identifier)
        try safeAssert(tokenIsCapitalizedIdentifier())
        let name = token.raw
        try advance()
        var typeVars = [String]()
        while token.type == .identifier {
            typeVars.append(token.raw)
            try advance()
        }
        // we immediately put type name in type lookup
        // because we might have a recursive type
        types[name] = MonoType.CustomType(name, typeVars.map{MonoType.TVar($0)})
        try eatNewlines()
        try safeAssert(token.type == .equal)
        try advance()
        try eatNewlines()
        var typeConstructors = [EIAST.ConstructorDefinition]()
        while(true) {
            typeConstructors.append(try typeConstructor(typeVars: typeVars))
            while token.type == .newline {
                try advance()
            }
            if token.type != .bar {
                break
            }
            try advance()
        }
        return EIAST.TypeDefinition(typeName: name, typeVars: typeVars, constructors: typeConstructors)
    }
    
    func typeConstructor(typeVars: [String]) throws -> EIAST.ConstructorDefinition {
        try safeAssert(token.type == .identifier)
        try safeAssert(tokenIsCapitalizedIdentifier())
        let name = token.raw
        try advance()
        var typeParameters = [MonoType]()
        while token.type != .newline && token.type != .bar && token.type != .endOfFile {
            typeParameters.append(try type(typeVars: typeVars))
        }
        return EIAST.ConstructorDefinition(constructorName: name, typeParameters: typeParameters)
    }
    
    /*
     For parsing a type. 'bounded' here means that we are allowed to use parametric types and the -> operator.
     */
    func type(typeVars: [String] = [String](), bounded: Bool = false, annotation: Bool = false) throws -> MonoType {
        var result: MonoType
        switch token.type {
        case .identifier:
            if try tokenIsCapitalizedIdentifier() {
                if types[token.raw] != nil {
                    // must have no arguments
                    let t = types[token.raw]
                    try advance()
                    switch t {
                    case .CustomType(let name, let parameterVars):
                        if !bounded {
                            // TODO: replace this with a proper error
                            try safeAssert(parameterVars.count == 0)
                        }
                        var parameters = [MonoType]()
                        for _ in 0..<parameterVars.count {
                            parameters.append(try type(typeVars: typeVars, annotation: annotation))
                        }
                        result =  MonoType.CustomType(name, parameters)
                    default:
                        result = t!
                    }
                } else {
                    throw ParserError.TypeIsNotKnown
                }
            } else {
                // "number" support hardcoded, I assume we might generalize this later
                // Lucas: Note that this doesn't account for degenerate cases like "numberANDTHENSOMERANDOMSTRINGAFTER"
                if annotation && token.raw.hasPrefix("number") {
                    let numCount = token.raw.suffix(token.raw.count - 6)
                    let counter = Int(numCount) ?? 0
                    result = MonoType.TSuper("number", counter)
                    try advance()
                }
                else if typeVars.contains(token.raw) {
                    result = MonoType.TVar(token.raw)
                    try advance()
                } else {
                    throw ParserError.UnexpectedToken
                }
            }
        case .leftParan:
            try advance()
            let t1 = try type(typeVars: typeVars, bounded: true, annotation: annotation)
            if token.type == .rightParan {
                result = t1
                try safeAssert(token.type == .rightParan); try advance()
                break
            }
            try safeAssert(token.type == .comma)
            try advance()
            let t2 = try type(typeVars: typeVars, bounded: true, annotation: annotation)
            if token.type == .rightParan {
                result = MonoType.TupleType(t1, t2, nil)
                try safeAssert(token.type == .rightParan); try advance()
                break
            }
            try safeAssert(token.type == .comma)
            try advance()
            let t3 = try type(typeVars: typeVars, bounded: true, annotation: annotation)
            if token.type == .rightParan {
                result = MonoType.TupleType(t1, t2, t3)
                try safeAssert(token.type == .rightParan); try advance()
                break
            }
            throw ParserError.MaxTupleSizeIsThree
        default:
            throw ParserError.NotImplemented
        }
        if bounded && token.type == .arrow {
            try advance()
            result = result => (try type(typeVars: typeVars, bounded:true, annotation: annotation))
        }
        return result
    }
    
    func declaration() throws -> EIAST.Declaration {
        try safeAssert(token.type == .identifier)
        let name = token.raw
        try advance()
        if token.type == .colon {
            // we have a type annotation!
            try advance()
            // TODO: Currently I don't use the annoation, but I assume we'll want
            // to use it for type annotation.
            let _ = try type(bounded: true, annotation: true)
            while token.type == .newline { try advance() }
            try safeAssert(token.type == .identifier)
            try safeAssert(token.raw == name)
            try advance()
        }
        
        // for now we assume parameters are strings rather than patterns
        var parameters = [String]()
        while token.type == .identifier {
            parameters.append(token.raw)
            try advance()
        }
        try eatNewlines()
        try safeAssert(token.type == .equal)
        try advance()
        try eatNewlines()
        var node = try funcAppableExpression()
        for parameter in parameters.reversed() {
            node = EIAST.Function(parameter: parameter, body: node)
        }
        return EIAST.Declaration(name: name, body: node)
    }
    
    func funcAppableExpression() throws -> EINode {
        var result = try andableExpression()
        try eatNewlines()
        while true {
            switch token.type {
            case .rightFuncApp:
                try advance()
                result = EIAST.FunctionApplication(function: try andableExpression(), argument: result, functionApplicationType: .RightArrow)
                try eatNewlines()
            case .leftFuncApp:
                try advance()
                result = EIAST.FunctionApplication(function: result, argument: try andableExpression(), functionApplicationType: .LeftArrow)
                try eatNewlines()
            default:
                return result
            }
        }
    }
    
    func andableExpression() throws -> EINode {
        var result = try orableExpression()
        while true {
            switch token.type {
            case .ampersandampersand:
                try advance()
                result = EIAST.BinaryOp(result, try orableExpression(), .and)
            default:
                return result
            }
        }
    }
    
    func orableExpression() throws -> EINode {
        var result = try equatableExpression()
        while true {
            switch token.type {
            case .barbar:
                try advance()
                result = EIAST.BinaryOp(result, try equatableExpression(), .or)
            default:
                return result
            }
        }
    }
    
    func equatableExpression() throws -> EINode {
        if token.type == .not {
            try advance()
            return EIAST.UnaryOp(operand: try equatableExpression(), type: .not)
        }
        var result = try cattitiveExpression()
        while true {
            switch token.type {
            case .equalequal:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .eq)
            case .notequal:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .ne)
            case .lessequal:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .le)
            case .greaterequal:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .ge)
            case .lessthan:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .lt)
            case .greaterthan:
                try advance()
                result = EIAST.BinaryOp(result, try cattitiveExpression(), .gt)
            default:
                return result
            }
        }
    }
    
    func cattitiveExpression() throws -> EINode {
        let result = try additiveExpression()
        // These operators are right associative
        switch token.type {
        case .plusplus:
            try advance()
            return EIAST.BinaryOp(result, try cattitiveExpression(), .concatenate)
        case .coloncolon:
            try advance()
            return EIAST.BinaryOp(result, try cattitiveExpression(), .push_left)
        default:
            return result
        }
    }
    
    func additiveExpression() throws -> EINode {
        var result = try multiplicativeExpression()
        while true {
            switch token.type {
            case .plus:
                try advance()
                result = EIAST.BinaryOp(result, try multiplicativeExpression(), .add)
            case .minus:
                try advance()
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
                try advance()
                result = EIAST.BinaryOp(result, try funcativeExpression(), .multiply)
            case .forwardSlash:
                try advance()
                result = EIAST.BinaryOp(result, try funcativeExpression(), .divide)
            default:
                return result
            }
        }
    }
    
    func funcativeExpression() throws -> EINode {
        try eatNewlines()
        var result = try unaryExpression()
        while tokenCouldStartExpression() {
            result = EIAST.FunctionApplication(function: result, argument: try unaryExpression())
        }
        //while token.type == .newline { try advance() }
        return result
    }

    func tokenCouldStartExpression() -> Bool {
        return token.type == .leftParan || token.type == .leftSquare || token.type == .identifier || token.type == .number || token.type == .string
    }

    func unaryExpression() throws -> EINode {
        let result: EINode
        switch token.type {
        case .leftParan:
            try advance()
            let v1 = try funcAppableExpression()
            if token.type == .comma {
                try advance()
                let v2 = try funcAppableExpression()
                if token.type == .comma {
                    try advance()
                    let v3 = try funcAppableExpression()
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
            try advance()
        case .leftSquare:
            try advance()
            var items = [EINode]()
            while token.type != .rightSquare {
                let expr = try funcAppableExpression()
                items.append(expr)
                if token.type == .comma { try advance() }
            }
            try advance()
            result = EIAST.List(items)
        case .identifier:
            if try tokenIsCapitalizedIdentifier() {
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
        case .string:
            result = try string()
        default:
            throw ParserError.UnexpectedToken
        }
        return result
    }
    
    func anonymousFunction() throws -> EINode {
        try safeAssert(token.type == .backSlash)
        try advance()
        try safeAssert(token.type == .identifier)
        var parameters = [String]()
        while token.type == .identifier {
            parameters.append(token.raw)
            try advance()
        }
        try safeAssert(token.type == .arrow)
        try advance()
        var node = try funcAppableExpression()
        for parameter in parameters.reversed() {
            node = EIAST.Function(parameter: parameter, body: node)
        }
        return node
    }
    
    func variable() throws -> EINode {
        try safeAssert(token.type == .identifier)
        let name = token.raw
        try advance()
        return EIAST.Variable(name: name)
    }
    
    func typeExpression() throws -> EINode {
        switch token.raw {
        case "NOVALUE": // Special case for NOVALUE
            try advance()
            return EIAST.NoValue()
        case "True":
            try advance()
            return EIAST.Boolean(true)
        case "False":
            try advance()
            return EIAST.Boolean(false)
        default:
            return try variable()
        }
    }
    
    func tokenIsCapitalizedIdentifier() throws -> Bool {
        if token.type != .identifier { return false }
        try safeAssert(token.raw.count >= 1)
        let first = token.raw.first
        return first!.isUppercase
    }
    
    func ifExpression() throws -> EINode {
        try safeAssert(token.type == .IF)
        var conditions = [EINode]()
        var branches = [EINode]()
        while token.type == .IF {
            try advance()
            try conditions.append(funcAppableExpression())
            try eatNewlines()
            try safeAssert(token.type == .THEN)
            try advance()
            try branches.append(funcAppableExpression())
            try eatNewlines()
            try safeAssert(token.type == .ELSE)
            try advance()
        }
        try branches.append(funcAppableExpression())
        return EIAST.IfElse(conditions: conditions, branches: branches)
    }
    
    func number() throws -> EINode {
        try safeAssert(token.type == .number || token.type == .minus)
        let result: EINode
        var minus = false
        if token.type == .minus {
            minus = true
            try advance()
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
        try advance()
        return result
    }
    
    func string() throws -> EINode {
        try safeAssert(token.type == .string)
        let value = token.raw
        try advance()
        return EIAST.Str(value)
    }
}
