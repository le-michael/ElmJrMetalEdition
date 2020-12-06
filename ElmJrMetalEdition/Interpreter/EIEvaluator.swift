//
//  Evaluator.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EIEvaluator {
    
    enum EvaluatorError : Error {
        case DivisionByZero
        case NotImplemented
    }
    
    init () {}
    
    func interpret(_ text : String) throws -> EINode {
        let ast = try EIParser(text: text).parse()
        if ast is EIParser.Function {
            return ast
        }
        return try evaluate(ast, [:])
    }
    
    /**
    Given an AST subtree 'evaluate' will attempt to find the value of the tree and return it as a Literal.
    Note that a Literal is itself an ASTNode but it won't contain things like function calls / if then ... else ...
    Scope contains all the variable/functions that can be seen during this evaluation, including things at global scope.
     */
    func evaluate(_ node : EINode, _ scope : [String:EINode]) throws -> EILiteral {
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
        default:
            throw EvaluatorError.NotImplemented
        }
    }
}
