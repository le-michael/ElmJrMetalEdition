//
//  Evaluator.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EIEvaluator {
    var globals : [String:EINode]
    
    enum EvaluatorError : Error {
        case DivisionByZero
        case UnknownIdentifier
        case VariableShadowing
        case TooManyArguments
        case ConditionMustBeBool
        case UnsupportedOperation
        case NotImplemented
        case TypeIsNotAFunction
    }
    
    init () {
        globals = [String:EINode]()
    }
    
    /**
     Evaluates an expression or declaration.
     Intended to be used in an Elm REPL.
     Declarations will be stored to the 'globals' dictionary.
     */
    func interpret(_ text : String) throws -> EINode {
        let ast = try EIParser(text: text).parse()
        let (result, _) = try evaluate(ast, globals)
        return result
    }
    
    func compile(_ text: String) throws -> EINode {
        let parser = EIParser(text: text)
        while (!parser.isDone()) {
            let decl = try parser.parseDeclaration()
            try evaluate(decl, globals)
        }
        // For now we will return the final value of the view variable
        if let view = globals["view"] {
            let (result, _) = try evaluate(view, globals)
            return result
        } else {
            throw EvaluatorError.NotImplemented
        }
    }
    
    /**
     Given an AST subtree 'evaluate' will attempt to evaluate (or at least simplify the tree).
     It returns a 2-tuple (EINode, Bool) consisting respectively of the simplified tree and whether the tree could be evaluated.
     Scope contains all the variable/functions that can be seen during this evaluation, including things at global scope.
     If a variable is in scope but does not have a value is will be set to EIParser.NoValue.
     */
    @discardableResult func evaluate(_ node : EINode, _ scope : [String:EINode]) throws -> (EINode, Bool) {
        switch node {
        case let literal as EILiteral:
            return (literal, true)
        case let unOp as EIParser.UnaryOp:
            let (operand, isEvaluated) = try evaluate(unOp.operand, scope)
            if !isEvaluated { return (EIParser.UnaryOp(operand: operand, type: unOp.type), false) }
            switch unOp.type {
            case .not:
                let asBool = operand as? EIParser.Boolean
                guard asBool != nil else {
                    throw EvaluatorError.UnsupportedOperation
                }
                return (EIParser.Boolean(!asBool!.value), true)
            }
        case let binOp as EIParser.BinaryOp:
                // TODO: In the future we should should should instead have a 'numeric' type
            var (left, isLeftEvaled) = try evaluate(binOp.leftOperand, scope);
            var (right, isRightEvaled) = try evaluate(binOp.rightOperand, scope);
            if !isLeftEvaled || !isRightEvaled { return (EIParser.BinaryOp(left, right, binOp.type), false)}
            // handle case where both operands are booleans
            if let leftBool = left as? EIParser.Boolean,
               let rightBool = right as? EIParser.Boolean {
                let result : EINode
                switch binOp.type {
                case .and:
                    result = EIParser.Boolean(leftBool.value && rightBool.value)
                case .or:
                    result = EIParser.Boolean(leftBool.value || rightBool.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
            }
            guard (left as? EIParser.Boolean == nil && right as? EIParser.Boolean == nil) else {
                // cannot perform binary op with one bool and one non-bool
                throw EvaluatorError.UnsupportedOperation
            }
            // handle case where both operands are integers
            if let leftInt = left as? EIParser.Integer,
               let rightInt = right as? EIParser.Integer {
                let result : EINode
                switch binOp.type {
                case .add:
                    result = EIParser.Integer(leftInt.value + rightInt.value)
                case .subtract:
                    result = EIParser.Integer(leftInt.value - rightInt.value)
                case .multiply:
                    result = EIParser.Integer(leftInt.value * rightInt.value)
                case .divide:
                    if rightInt.value == 0 { throw EvaluatorError.DivisionByZero }
                    result = EIParser.Integer(leftInt.value / rightInt.value)
                case .eq:
                    result = EIParser.Boolean(leftInt.value == rightInt.value)
                case .ne:
                    result = EIParser.Boolean(leftInt.value != rightInt.value)
                case .le:
                    result = EIParser.Boolean(leftInt.value <= rightInt.value)
                case .ge:
                    result = EIParser.Boolean(leftInt.value >= rightInt.value)
                case .lt:
                    result = EIParser.Boolean(leftInt.value < rightInt.value)
                case .gt:
                    result = EIParser.Boolean(leftInt.value > rightInt.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
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
                let result : EINode
                switch binOp.type {
                case .add:
                    result = EIParser.FloatingPoint(leftFloat.value + rightFloat.value)
                case .subtract:
                    result = EIParser.FloatingPoint(leftFloat.value - rightFloat.value)
                case .multiply:
                    result = EIParser.FloatingPoint(leftFloat.value * rightFloat.value)
                case .divide:
                    if rightFloat.value == 0 { throw EvaluatorError.DivisionByZero }
                    result = EIParser.FloatingPoint(leftFloat.value / rightFloat.value)
                case .eq:
                    result = EIParser.Boolean(leftFloat.value == rightFloat.value)
                case .ne:
                    result = EIParser.Boolean(leftFloat.value != rightFloat.value)
                case .le:
                    result = EIParser.Boolean(leftFloat.value <= rightFloat.value)
                case .ge:
                    result = EIParser.Boolean(leftFloat.value >= rightFloat.value)
                case .lt:
                    result = EIParser.Boolean(leftFloat.value < rightFloat.value)
                case .gt:
                    result = EIParser.Boolean(leftFloat.value > rightFloat.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
            }
            // if we made it this far at least one operand is not an int or float
            throw EvaluatorError.NotImplemented
        case let variable as EIParser.Variable:
            let lookup : EINode? = scope[variable.name]
            switch lookup {
            case .some(let value):
                if value as? EIParser.NoValue != nil {
                    // variable is in scope but hasn't been assigned a value
                    return (variable, false)
                }
                // normal behavior
                return (value, true)
            default:
                // unexpected variable
                throw EvaluatorError.UnknownIdentifier
            }
        case let decl as EIParser.Declaration:
            let (body, bodyEvaled) = try evaluate(decl.body, globals)
            assert(bodyEvaled == true)
            if globals[decl.name] != nil {
                throw EvaluatorError.VariableShadowing
            }
            globals[decl.name] = body
            return (EIParser.Declaration(name: decl.name, body: body), true)
        case let function as EIParser.Function:
            var newScope = scope
            newScope[function.parameter] = EIParser.NoValue()
            let (body, _) = try evaluate(function.body, newScope)
            let result = EIParser.Function(parameter: function.parameter, body: body)
            return (result, true)
        case let funcApp as EIParser.FunctionApplication:
            let (node, _) = try evaluate(funcApp.function, scope)
            let function = node as? EIParser.Function
            if function == nil {
                throw EvaluatorError.TypeIsNotAFunction
            }
            let (argument, argumentEvaled) = try evaluate(funcApp.argument, scope)
            let (result,_) = try evaluate(function!.body, [function!.parameter : argument])
            // TODO: Technically I think using 'argumentEvaled' might break on some fringe cases with nested anonymous functions
            return (result, argumentEvaled)
        case let ifElse as EIParser.IfElse:
            assert(ifElse.branches.count == ifElse.conditions.count + 1)
            var conditions : [EINode] = []
            var branches : [EINode] = []
            // evaluate conditions and branches
            var couldEval = true
            for i in 0..<ifElse.conditions.count {
                let (condition, condEvaluated) = try evaluate(ifElse.conditions[i], scope)
                let (branch, branchEvaled) = try evaluate(ifElse.branches[i], scope)
                couldEval = couldEval && condEvaluated && branchEvaled
                conditions.append(condition)
                branches.append(branch)
            }
            if !couldEval {
                let result = EIParser.IfElse(conditions: conditions, branches: branches)
                return (result, false)
            }
            
            for i in 0..<conditions.count {
                let condition = conditions[i] as? EIParser.Boolean
                guard condition != nil else {
                    throw EvaluatorError.ConditionMustBeBool
                }
                // if it's true, result is ith branch
                if condition!.value {
                    return (branches[i], true)
                }
            }
            // if no conditons are true we return the else ast
            return (branches.last!, true)
        default:
            throw EvaluatorError.NotImplemented
        }
    }
}
