//
//  EIAST.swift
//  ElmJrMetalEdition
//
//  Created by Wyatt Wismer on 2021-01-10.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

class EIAST {
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
    
    class NoValue : EINode {
        init(){}
        var description: String { return "NOVALUE" }
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

}
