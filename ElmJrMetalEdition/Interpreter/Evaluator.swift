//
//  Evaluator.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class Evaluator {
    
    enum EvaluatorError : Error {
        case DivisionByZero
        case NotImplemented
    }
    
    init () {}
    
    func interpret(_ text : String) throws -> ASTNode {
        let ast = try Parser(text: text).parse()
        if ast is Parser.Function {
            return ast
        }
        return try evaluate(ast, [:])
    }
    
    func evaluate(_ node : ASTNode, _ locals : [String:ASTNode]) throws -> Literal {
        switch node {
        case let literal as Literal:
            return literal
        case let binOp as Parser.BinaryOp:
                // If one argument is a float convert both to float
                // TODO: In the future we should should should instead have a 'numeric' type
            var left = try evaluate(binOp.leftOperand, locals);
            var right = try evaluate(binOp.rightOperand, locals);
            // handle case where both operands are integers
            if let leftInt = left as? Parser.Integer,
               let rightInt = right as? Parser.Integer {
                switch binOp.type {
                case .add:
                    return Parser.Integer(leftInt.value + rightInt.value)
                case .subtract:
                    return Parser.Integer(leftInt.value - rightInt.value)
                case .multiply:
                    return Parser.Integer(leftInt.value * rightInt.value)
                case .divide:
                    if rightInt.value == 0 { throw EvaluatorError.DivisionByZero }
                    return Parser.Integer(leftInt.value / rightInt.value)
                }
            }
            // handle case where at least one operand is not an integer
            // we cast any integers to floats
            if let leftInt = left as? Parser.Integer {
                left = Parser.FloatingPoint(Float(leftInt.value))
            }
            if let rightInt = right as? Parser.Integer {
                right = Parser.FloatingPoint(Float(rightInt.value))
            }
            if let leftFloat = left as? Parser.FloatingPoint,
               let rightFloat = right as? Parser.FloatingPoint {
                switch binOp.type {
                case .add:
                    return Parser.FloatingPoint(leftFloat.value + rightFloat.value)
                case .subtract:
                    return Parser.FloatingPoint(leftFloat.value - rightFloat.value)
                case .multiply:
                    return Parser.FloatingPoint(leftFloat.value * rightFloat.value)
                case .divide:
                    if rightFloat.value == 0 { throw EvaluatorError.DivisionByZero }
                    return Parser.FloatingPoint(leftFloat.value / rightFloat.value)
                }
            }
            // if we made it this far at least one operand is not an int or float
            throw EvaluatorError.NotImplemented
        default:
            throw EvaluatorError.NotImplemented
        }
    }
}
