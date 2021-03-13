//
//  EIAST.swift
//  ElmJrMetalEdition
//
//  Created by Wyatt Wismer on 2021-01-10.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

// Alias variables and type variables to strings
typealias Var = String
typealias TVar = String

// monomorphic types
enum MonoType: Equatable, CustomStringConvertible {
    case TVar(TVar)
    case TCon(String)
    case TSuper(String, Int)
    case TNoValue(String) // For NoValue nodes - the string acts as an identifier used in typechecking
    indirect case TArr(MonoType, MonoType)
    indirect case CustomType(String, [MonoType]) // Corresponds to "parameterized types"
    indirect case TupleType(MonoType, MonoType, MonoType?) // Corresponds to 2 and 3 tuples
    
    static func => (left : MonoType, right : MonoType) -> MonoType {
        return TArr(left, right)
    }
    
    // like description but wraps with () if needed
    func wrappedDescription() -> String {
        let raw = "\(self)"
        switch self {
        case .CustomType(_, let params):
            if params.count == 0 {
                return raw
            } else {
                return "(\(raw))"
            }
        case .TArr(_, _):
            return "(\(raw))"
        default:
            return raw
        }
    }
    
    var description: String {
        switch self {
        case .TVar(let v):
            return v
        case .TCon(let con):
            return con
        case .TSuper(let sup, let inst):
            return sup + (inst == 0 ? "" : String(inst))
        case .TArr(let t1, let t2):
            switch t1 {
            case .TArr(_, _):
                return "(\(t1.description)) -> \(t2.description)"
            default:
                return "\(t1.description) -> \(t2.description)"
            }
        case .CustomType(let typeName, let typeParameters):
            if typeParameters.count == 0 {
                return "\(typeName)"
            } else {
                return "\(typeName) \(typeParameters.map{"\($0.wrappedDescription())"}.joined(separator: " "))"
            }
        case .TupleType(let t1, let t2, let t3):
            return "(\(t1), \(t2)\(t3 != nil ? ", \(t3!)" : ""))"
        case .TNoValue:
            return "NoValue"
        }
    }
}

class EIAST {
    class BinaryOp: EINode {
        var leftOperand: EINode
        var rightOperand: EINode
        var type: BinaryOpType

        enum BinaryOpType: String {
            case add = "+", subtract = "-", multiply = "*", divide = "/"
            case eq = "==", ne = "/=", le = "<=", ge = ">=", lt = "<", gt = ">"
            case and = "&&", or = "||", concatenate="++", push_left="::"
        }
        
        init(_ leftOperand: EINode, _ rightOperand: EINode, _ type: BinaryOpType) {
            self.leftOperand = leftOperand
            self.rightOperand = rightOperand
            self.type = type
        }

        var description: String {
            return "(\(leftOperand)\(type.rawValue)\(rightOperand))"
        }
    }
    
    class UnaryOp: EINode {
        var operand: EINode
        var type: UnaryOpType
        
        enum UnaryOpType: String {
            case not
        }
        
        init(operand: EINode, type: UnaryOpType) {
            self.operand = operand
            self.type = type
        }
        
        var description: String {
            return "(\(type.rawValue) \(operand))"
        }
    }

    class FloatingPoint: EILiteral {
        var value: Float

        init(_ value: Float) {
            self.value = value
        }

        var description: String {
            return "\(value)"
        }
    }
    
    class Integer: EILiteral {
        var value: Int

        init(_ value: Int) {
            self.value = value
        }

        var description: String {
            return "\(value)"
        }
    }

    class Boolean: EILiteral {
        var value: Bool
        
        init(_ value: Bool) {
            self.value = value
        }
        
        var description: String {
            return value ? "True" : "False"
        }
    }
    
    class NoValue: EINode {
        var typeInfo: MonoType
        var name: Var
        init() {
            typeInfo = MonoType.TNoValue("placeholder")
            name = ""
        }
        var description: String { return "NOVALUE" }
    }
    
    class IfElse: EINode {
        var conditions: [EINode]
        var branches: [EINode]
        
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
                index += 1
            }
            result += "\(branches[index])"
            return result
        }
    }
    
    class FunctionApplication: EINode {
        var function: EINode
        var argument: EINode
        var functionApplicationType: FunctionApplicationType
        
        enum FunctionApplicationType {
            case Normal
            case LeftArrow
            case RightArrow
        }
        
        init(function: EINode, argument: EINode, functionApplicationType: FunctionApplicationType = .Normal) {
            self.function = function
            self.argument = argument
            self.functionApplicationType = functionApplicationType
        }

        var description: String {
            switch functionApplicationType {
            case .Normal:
                return "(\(function) \(argument))"
            case .LeftArrow:
                return "\(function) \n<| \(argument)"
            case .RightArrow:
                return "\(argument) \n|> \(function)"
            }
        }
    }
    
    class Variable: EINode {
        var name: String
        
        init(name: String) {
            self.name = name
        }
        
        var description: String {
            return name
        }
    }
    
    class Function: EINode {
        var parameter: String // Will be replaced by a pattern later
        var body: EINode
        
        init(parameter: String, body: EINode) {
            self.parameter = parameter
            self.body = body
        }

        var description: String {
            // display as anonymous function
            return "(\\\(parameter) -> \(body))"
        }
    }
    
    class Declaration: EINode {
        var name: String
        var body: EINode
        
        init(name: String, body: EINode) {
            self.name = name
            self.body = body
        }
        
        var description: String {
            return "\(name) = \(body)"
        }
    }
    
    class ConstructorDefinition : EINode {
        var constructorName : String
        var typeParameters : [MonoType]
        init(constructorName: String, typeParameters: [MonoType]) {
            self.constructorName = constructorName
            self.typeParameters = typeParameters
        }
        var description: String {
            return "\(constructorName)\(typeParameters.count > 0 ? " " :"")\(typeParameters.map{"\($0.wrappedDescription())"}.joined(separator: " "))"
        }
    }

    class TypeDefinition : EINode {
        var typeName : String
        var typeVars : [String]
        var constructors : [ConstructorDefinition]
        init(typeName: String, typeVars: [String], constructors: [ConstructorDefinition]) {
            self.typeName = typeName
            self.typeVars = typeVars
            self.constructors = constructors
        }
        var description: String {
            let beforeEqual = "type \(typeName) \(typeVars.joined(separator: " "))\(typeVars.count > 0 ? " " :"")"
            let afterEqual = " \(constructors.map{"\($0)"}.joined(separator: " | "))"
            return "\(beforeEqual)=\(afterEqual)"
        }
    }
    
    class ConstructorInstance : EINode {
        var constructorName: String
        var parameters: [EINode]
        init(constructorName: String, parameters:[EINode]) {
            self.constructorName = constructorName
            self.parameters = parameters
        }
        var description: String {
            if parameters.count == 0 {
                return constructorName
            } else {
                return "(\(constructorName) \(parameters.map{"\($0)"}.joined(separator: " ")))"
            }
        }
    }
    
    class Tuple : EINode {
        var v1 : EINode
        var v2 : EINode
        var v3 : EINode?
        
        init(_ v1: EINode, _ v2: EINode, _ v3: EINode?) {
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
        }
        
        var description: String {
            return "(\(v1), \(v2)\(v3 != nil ? ", \(v3!)" : ""))"
        }
    }
    
    class List : EINode {
        var items : [EINode]
        
        init(_ items: [EINode]) {
            self.items = items
        }
        
        var description: String {
            return "[\(items.map{"\($0)"}.joined(separator: ", "))]"
        }
    }
}
