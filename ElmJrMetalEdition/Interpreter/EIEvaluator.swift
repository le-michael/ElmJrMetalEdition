//
//  Evaluator.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EIEvaluator {
    var globals : [String:EIParser.Function]
    
    enum EvaluatorError : Error {
        case DivisionByZero
        case UnknownIdentifier
        case VariableShadowing
        case TooManyArguments
        case NotImplemented
    }
    
    init () {
        globals = [String:EIParser.Function]()
    }
    
    /**
     Evaluates an expression or declaration.
     Intended to be used in an Elm REPL.
     Declarations will be stored to the 'globals' dictionary.
     */
    func interpret(_ text : String) throws -> EINode {
        let ast = try EIParser(text: text).parse()
        if let function = ast as? EIParser.Function {
            // functions are added to the global scope
            globals[function.name] = function
            return ast
        }
        return try evaluate(ast, globals)
    }
    
    func compile(_ text: String) throws -> EINode {
        let parser = EIParser(text: text)
        while (!parser.isDone()) {
            let function = try parser.parseDeclaration()
            globals[function.name] = function
        }
        // For now we will return the final value of the view variable
        if let view = globals["view"] {
            return try evaluate(view.body, globals)
        } else {
            throw EvaluatorError.NotImplemented
        }
    }
    
    /**
    Given an AST subtree 'evaluate' will attempt to find the value of the tree and return it as a Literal.
    Note that a Literal is itself an ASTNode but it won't contain things like function calls / if then ... else ...
    Scope contains all the variable/functions that can be seen during this evaluation, including things at global scope.
     */
    func evaluate(_ node : EINode, _ scope : [String:EIParser.Function]) throws -> EILiteral {
        switch node {
        case let literal as EILiteral:
            return literal
        case let binOp as EIParser.BinaryOp:
                // If one argument is a float convert both to float
                // TODO: In the future we should should should instead have a 'numeric' type
            var left = try evaluate(binOp.leftOperand, scope);
            var right = try evaluate(binOp.rightOperand, scope);
            // handle case where both operands are integers
            if let leftInt = left as? EIParser.Integer,
               let rightInt = right as? EIParser.Integer {
                switch binOp.type {
                case .add:
                    return EIParser.Integer(leftInt.value + rightInt.value)
                case .subtract:
                    return EIParser.Integer(leftInt.value - rightInt.value)
                case .multiply:
                    return EIParser.Integer(leftInt.value * rightInt.value)
                case .divide:
                    if rightInt.value == 0 { throw EvaluatorError.DivisionByZero }
                    return EIParser.Integer(leftInt.value / rightInt.value)
                }
            }
            // handle case where at least one operand is not an integer
            // we cast any integers to floats
            if let leftInt = left as? EIParser.Integer {
                left = EIParser.FloatingPoint(Float(leftInt.value))
            }
            if let rightInt = right as? EIParser.Integer {
                right = EIParser.FloatingPoint(Float(rightInt.value))
            }
            if let leftFloat = left as? EIParser.FloatingPoint,
               let rightFloat = right as? EIParser.FloatingPoint {
                switch binOp.type {
                case .add:
                    return EIParser.FloatingPoint(leftFloat.value + rightFloat.value)
                case .subtract:
                    return EIParser.FloatingPoint(leftFloat.value - rightFloat.value)
                case .multiply:
                    return EIParser.FloatingPoint(leftFloat.value * rightFloat.value)
                case .divide:
                    if rightFloat.value == 0 { throw EvaluatorError.DivisionByZero }
                    return EIParser.FloatingPoint(leftFloat.value / rightFloat.value)
                }
            }
            // if we made it this far at least one operand is not an int or float
            throw EvaluatorError.NotImplemented
        case let funcCall as EIParser.FunctionCall:
            if let function = scope[funcCall.name] {
                if function.parameters.count < funcCall.arguments.count {
                    throw EvaluatorError.TooManyArguments
                }
                if function.parameters.count < funcCall.arguments.count {
                    // TODO: Support partial function application
                    // One way we could do this is by storing already set parameters
                    throw EvaluatorError.NotImplemented
                }
                // map function parameters to funcCall arguments
                var newScope = globals;
                for i in 0..<function.parameters.count {
                    let key = function.parameters[i]
                    let value = try evaluate(funcCall.arguments[i], scope)
                    if newScope[key] != nil {
                        throw EvaluatorError.VariableShadowing
                    }
                    // note that variables are just treated as functions with no parameters
                    newScope[key] = EIParser.Function(name: key, parameters: [], body: value)
                }
                return try evaluate(function.body, newScope)
            } else {
                throw EvaluatorError.UnknownIdentifier
            }
        default:
            throw EvaluatorError.NotImplemented
        }
    }
}
