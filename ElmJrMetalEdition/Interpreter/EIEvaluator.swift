//
//  Evaluator.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EIEvaluator {
    var parser: EIParser
    var globals: [String: EINode]
    
    
    enum EvaluatorError: Error {
        case DivisionByZero
        case UnknownIdentifier
        case VariableShadowing
        case TooManyArguments
        case ConditionMustBeBool
        case UnsupportedOperation
        case NotImplemented
        case TypeIsNotAFunction
    }
    
    init() {
        globals = [String: EINode]()
        parser = EIParser()
    }
    
    /**
     Evaluates an expression or declaration.
     Intended to be used in an Elm REPL.
     Declarations will be stored to the 'globals' dictionary.
     */
    func interpret(_ text: String) throws -> EINode {
        try parser.appendText(text: text)
        let ast = try parser.parse()
        let (result, _) = try evaluate(ast, globals)
        return result
    }
    
    func compile(_ text: String) throws {
        try parser.appendText(text: text)
        while !parser.isDone() {
            let decl = try parser.parseDeclaration()
            try evaluate(decl, globals)
        }
    }
    
    /**
     Given an AST subtree 'evaluate' will attempt to evaluate (or at least simplify the tree).
     It returns a 2-tuple (EINode, Bool) consisting respectively of the simplified tree and whether the tree could be evaluated.
     Scope contains all the variable/functions that can be seen during this evaluation, including things at global scope.
     If a variable is in scope but does not have a value is will be set to EIAST.NoValue.
     */
    @discardableResult func evaluate(_ node: EINode, _ scope: [String: EINode]) throws -> (EINode, Bool) {
        switch node {
        case let literal as EILiteral:
            return (literal, true)
        case let unOp as EIAST.UnaryOp:
            let (operand, isEvaluated) = try evaluate(unOp.operand, scope)
            if !isEvaluated { return (EIAST.UnaryOp(operand: operand, type: unOp.type), false) }
            switch unOp.type {
            case .not:
                let asBool = operand as? EIAST.Boolean
                guard asBool != nil else {
                    throw EvaluatorError.UnsupportedOperation
                }
                return (EIAST.Boolean(!asBool!.value), true)
            }
        case let binOp as EIAST.BinaryOp:
            // TODO: In the future we should should should instead have a 'numeric' type
            var (left, isLeftEvaled) = try evaluate(binOp.leftOperand, scope)
            var (right, isRightEvaled) = try evaluate(binOp.rightOperand, scope)
            if !isLeftEvaled || !isRightEvaled { return (EIAST.BinaryOp(left, right, binOp.type), false) }
            // handle case where both operands are booleans
            if let leftBool = left as? EIAST.Boolean,
               let rightBool = right as? EIAST.Boolean
            {
                let result: EINode
                switch binOp.type {
                case .and:
                    result = EIAST.Boolean(leftBool.value && rightBool.value)
                case .or:
                    result = EIAST.Boolean(leftBool.value || rightBool.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
            }
            guard left as? EIAST.Boolean == nil, right as? EIAST.Boolean == nil else {
                // cannot perform binary op with one bool and one non-bool
                throw EvaluatorError.UnsupportedOperation
            }
            // handle case where both operands are integers
            if let leftInt = left as? EIAST.Integer,
               let rightInt = right as? EIAST.Integer
            {
                let result: EINode
                switch binOp.type {
                case .add:
                    result = EIAST.Integer(leftInt.value + rightInt.value)
                case .subtract:
                    result = EIAST.Integer(leftInt.value - rightInt.value)
                case .multiply:
                    result = EIAST.Integer(leftInt.value * rightInt.value)
                case .divide:
                    if rightInt.value == 0 { throw EvaluatorError.DivisionByZero }
                    result = EIAST.Integer(leftInt.value / rightInt.value)
                case .eq:
                    result = EIAST.Boolean(leftInt.value == rightInt.value)
                case .ne:
                    result = EIAST.Boolean(leftInt.value != rightInt.value)
                case .le:
                    result = EIAST.Boolean(leftInt.value <= rightInt.value)
                case .ge:
                    result = EIAST.Boolean(leftInt.value >= rightInt.value)
                case .lt:
                    result = EIAST.Boolean(leftInt.value < rightInt.value)
                case .gt:
                    result = EIAST.Boolean(leftInt.value > rightInt.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
            }
            // handle case where at least one operand is not an integer
            // we cast any integers to floats
            if let leftInt = left as? EIAST.Integer {
                left = EIAST.FloatingPoint(Float(leftInt.value))
            }
            if let rightInt = right as? EIAST.Integer {
                right = EIAST.FloatingPoint(Float(rightInt.value))
            }
            if let leftFloat = left as? EIAST.FloatingPoint,
               let rightFloat = right as? EIAST.FloatingPoint
            {
                let result: EINode
                switch binOp.type {
                case .add:
                    result = EIAST.FloatingPoint(leftFloat.value + rightFloat.value)
                case .subtract:
                    result = EIAST.FloatingPoint(leftFloat.value - rightFloat.value)
                case .multiply:
                    result = EIAST.FloatingPoint(leftFloat.value * rightFloat.value)
                case .divide:
                    if rightFloat.value == 0 { throw EvaluatorError.DivisionByZero }
                    result = EIAST.FloatingPoint(leftFloat.value / rightFloat.value)
                case .eq:
                    result = EIAST.Boolean(leftFloat.value == rightFloat.value)
                case .ne:
                    result = EIAST.Boolean(leftFloat.value != rightFloat.value)
                case .le:
                    result = EIAST.Boolean(leftFloat.value <= rightFloat.value)
                case .ge:
                    result = EIAST.Boolean(leftFloat.value >= rightFloat.value)
                case .lt:
                    result = EIAST.Boolean(leftFloat.value < rightFloat.value)
                case .gt:
                    result = EIAST.Boolean(leftFloat.value > rightFloat.value)
                default:
                    throw EvaluatorError.UnsupportedOperation
                }
                return (result, true)
            }
            // if we made it this far at least one operand is not an int or float
            throw EvaluatorError.NotImplemented
        case let variable as EIAST.Variable:
            let lookup: EINode? = scope[variable.name]
            switch lookup {
            case .some(let value):
                if value as? EIAST.NoValue != nil {
                    // variable is in scope but hasn't been assigned a value
                    return (variable, false)
                }
                // normal behavior
                return (value, true)
            default:
                // unexpected variable
                throw EvaluatorError.UnknownIdentifier
            }
        case let decl as EIAST.Declaration:
            var newScope = globals
            // put declaration name in scope to support recursion
            newScope[decl.name] = EIAST.NoValue()
            let (body, bodyEvaled) = try evaluate(decl.body, newScope)
            assert(bodyEvaled == true)
            if globals[decl.name] != nil {
                throw EvaluatorError.VariableShadowing
            }
            globals[decl.name] = body
            return (EIAST.Declaration(name: decl.name, body: body), true)
        case let typeDef as EIAST.TypeDefinition:
            for constructor in typeDef.constructors {
                let name = constructor.constructorName
                let varname = "_COMPILER_CONSTRUCTOR_INTERNAL"
                var vars = [EIAST.Variable]()
                for i in 0..<constructor.typeParameters.count {
                    vars.append(EIAST.Variable(name: "\(varname)\(i)"))
                }
                var node : EINode = EIAST.ConstructorInstance(constructorName: name, parameters: vars)
                for element in vars.reversed() {
                    node = EIAST.Function(parameter: element.name, body: node)
                }
                globals[name] = node
            }
            return (typeDef, true)
        case _ as EIAST.ConstructorDefinition:
            // This should never run
            throw EvaluatorError.NotImplemented
        case let inst as EIAST.ConstructorInstance:
            var newParameters = [EINode]()
            var evaled = true
            for parameter in inst.parameters {
                let (param, paramEvaled) = try evaluate(parameter, scope)
                evaled = evaled && paramEvaled
                newParameters.append(param)
            }
            return (EIAST.ConstructorInstance(constructorName: inst.constructorName, parameters: newParameters), evaled)
        case let tuple as EIAST.Tuple:
            let (val1, val1Evaled) = try evaluate(tuple.v1, scope)
            let (val2, val2Evaled) = try evaluate(tuple.v2, scope)
            var evaled = val1Evaled && val2Evaled
            if tuple.v3 != nil {
                let (val3, val3Evaled) = try evaluate(tuple.v3!, scope)
                evaled = evaled && val3Evaled
                return (EIAST.Tuple(val1, val2, val3), evaled)
            }
            return (EIAST.Tuple(val1, val2, nil), evaled)
        case let list as EIAST.List:
            var items = [EINode]()
            var evaled = true
            for item in list.items {
                let (newItem, itemEvaled) = try evaluate(item, scope)
                evaled = evaled && itemEvaled
                items.append(newItem)
            }
            return (EIAST.List(items), evaled)
        case let function as EIAST.Function:
            var newScope = scope
            newScope[function.parameter] = EIAST.NoValue()
            let (body, _) = try evaluate(function.body, newScope)
            let result = EIAST.Function(parameter: function.parameter, body: body)
            return (result, true)
        case let funcApp as EIAST.FunctionApplication:
            let (node, functionEvaled) = try evaluate(funcApp.function, scope)
            let (argument, argumentEvaled) = try evaluate(funcApp.argument, scope)
            if !functionEvaled {
                return (EIAST.FunctionApplication(function: node, argument: argument), false)
            }
            let function = node as? EIAST.Function
            if function == nil {
                throw EvaluatorError.TypeIsNotAFunction
            }
            var newScope = globals
            newScope[function!.parameter] = (argumentEvaled ? argument : EIAST.NoValue())
            let (result, _) = try evaluate(function!.body, newScope)
            return (result, argumentEvaled)
        case let ifElse as EIAST.IfElse:
            assert(ifElse.branches.count == ifElse.conditions.count + 1)
            for i in 0 ..< ifElse.conditions.count {
                let (condition, condEvaluated) = try evaluate(ifElse.conditions[i], scope)
                let (branch, branchEvaled) = try evaluate(ifElse.branches[i], scope)
                
                // check if anything could not be evaluated
                if !condEvaluated || !branchEvaled { return (node, false) }
                
                // check if condition is non-bool
                let conditionBool = condition as? EIAST.Boolean
                guard conditionBool != nil else {
                    throw EvaluatorError.ConditionMustBeBool
                }
                // if it's true, result is ith branch
                if conditionBool!.value {
                    return (branch, true)
                }
            }
            let (elseBranch, elseBranchEvaled) = try evaluate(ifElse.branches.last!, scope)
            if !elseBranchEvaled { return (node, false) }
            return (elseBranch, true)
        default:
            throw EvaluatorError.NotImplemented
        }
    }
    
    func subsitute(_ node: EINode, _ variable: String, _ value: EINode) -> EINode {
        switch node {
        case let literal as EILiteral:
            return literal
        case let unOp as EIAST.UnaryOp:
            let operand = subsitute(unOp.operand , variable, value)
            return EIAST.UnaryOp(operand: operand, type: unOp.type)
        case let binOp as EIAST.BinaryOp:
            let left = subsitute(binOp.leftOperand, variable, value)
            let right = subsitute(binOp.rightOperand, variable, value)
            return EIAST.BinaryOp(left, right, binOp.type)
        case let vari as EIAST.Variable:
            if vari.name == variable { return value }
            return vari
        case let decl as EIAST.Declaration:
            return EIAST.Declaration(name: decl.name, body: subsitute(decl.body, variable, value))
        case let typeDef as EIAST.TypeDefinition:
            return EIAST.TypeDefinition(
                typeName: typeDef.typeName, typeVars: typeDef.typeVars,
                constructors: typeDef.constructors.map{
                    subsitute($0, variable, value) as! EIAST.ConstructorDefinition
                })
        case let constDef as EIAST.ConstructorDefinition:
            return EIAST.ConstructorDefinition(constructorName: constDef.constructorName,
                                               typeParameters: constDef.typeParameters)
        case let inst as EIAST.ConstructorInstance:
            return EIAST.ConstructorInstance(constructorName: inst.constructorName,
                                             parameters: inst.parameters.map{ subsitute($0, variable, value) })
        case let tuple as EIAST.Tuple:
            return EIAST.Tuple(subsitute(tuple.v1, variable, value),
                               subsitute(tuple.v2, variable, value),
                               tuple.v3 != nil ? subsitute(tuple.v3!, variable, value) : nil)
        case let list as EIAST.List:
            return EIAST.List(list.items.map{ subsitute($0, variable, value) })
        case let function as EIAST.Function:
            return EIAST.Function(parameter: function.parameter, body: subsitute(function.body, variable, value))
        case let funcApp as EIAST.FunctionApplication:
            return EIAST.FunctionApplication(function: subsitute(funcApp.function, variable, value),
                                             argument: subsitute(funcApp.argument, variable, value))
        case let ifElse as EIAST.IfElse:
            return EIAST.IfElse(conditions: ifElse.conditions.map{subsitute($0, variable, value)},
                                branches: ifElse.branches.map{subsitute($0, variable, value)})
        case _ as EIAST.NoValue:
            return EIAST.NoValue()
        default:
            // This will never run
            assert(false);
            return EIAST.NoValue()
        }
    }
}
