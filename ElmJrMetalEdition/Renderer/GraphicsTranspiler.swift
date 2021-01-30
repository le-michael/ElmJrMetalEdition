//
//  GraphicsTranspiler.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-01-29.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
 
func transpile(node: EINode){
    print("--------------------")
    switch node {
    case let literal as EILiteral:
        print(literal)
    case let unOp as EIAST.UnaryOp:
        print(unOp)
    case let binOp as EIAST.BinaryOp:
        print(binOp)
    case let decl as EIAST.Declaration:
        print(decl)
    case let typeDef as EIAST.TypeDefinition:
        print(typeDef)
    case _ as EIAST.ConstructorDefinition:
        print("nope")
        
    case let inst as EIAST.ConstructorInstance:
        
        switch inst.constructorName {
        case let scene as "Scene":
            print("test")
        default:
            print("test")
        }
        
        
        
        var newParams = [EINode]()
        for parameter in inst.parameters {
            switch parameter {
            case let parameter as EIAST.ConstructorInstance:
                print(parameter.parameters)
            default:
                return
            }
        }
    
    case let tuple as EIAST.Tuple:
        print(tuple)
    case let list as EIAST.List:
        print(list)
    case let function as EIAST.Function:
        print(function)
    case let funcApp as EIAST.FunctionApplication:
        print(funcApp)
    case let ifElse as EIAST.IfElse:
        print(ifElse)
    default:
        print("default")
    }
}
