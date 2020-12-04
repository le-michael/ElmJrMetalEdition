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
    
    init () {
        
    }
    
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
        case let obj as Parser.BinaryOp:
                // If one argument is a float convert both to float
                // TODO: In the future we should should should instead have a 'numeric' type
            var left = try evaluate(obj.leftOperand, locals);
            var right = try evaluate(obj.rightOperand, locals);
            // handle case where both operands are integers
            if let leftInt = left as? Parser.Integer,
               let rightInt = right as? Parser.Integer {
                switch obj {
                case _ as Parser.BinaryOpAdd:
                    return Parser.Integer(leftInt.value + rightInt.value)
                case _ as Parser.BinaryOpSubtract:
                    return Parser.Integer(leftInt.value - rightInt.value)
                case _ as Parser.BinaryOpMultiply:
                    return Parser.Integer(leftInt.value * rightInt.value)
                case _ as Parser.BinaryOpDivide:
                    if rightInt.value == 0 { throw EvaluatorError.DivisionByZero }
                    return Parser.Integer(leftInt.value / rightInt.value)
                default:
                    throw EvaluatorError.NotImplemented
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
                switch obj {
                case _ as Parser.BinaryOpAdd:
                    return Parser.FloatingPoint(leftFloat.value + rightFloat.value)
                case _ as Parser.BinaryOpSubtract:
                    return Parser.FloatingPoint(leftFloat.value - rightFloat.value)
                case _ as Parser.BinaryOpMultiply:
                    return Parser.FloatingPoint(leftFloat.value * rightFloat.value)
                case _ as Parser.BinaryOpDivide:
                    if rightFloat.value == 0 { throw EvaluatorError.DivisionByZero }
                    return Parser.FloatingPoint(leftFloat.value / rightFloat.value)
                default:
                    throw EvaluatorError.NotImplemented
                }
            }
            // if we made it this far at least one operand is not an int or float
            throw EvaluatorError.NotImplemented
        default:
            throw EvaluatorError.NotImplemented
        }
    }
}
