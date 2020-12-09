//
//  EITypeInferencer.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-06.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol Substitutable {}

class EITypeInferencer {
    
    init () {}
    
    // A type environment from variables to schemes
    typealias TypeEnv = [Var : Scheme]
    
    // Alias variables and type variables to strings
    typealias Var = String
    typealias TVar = String
    
    // global variables: The type environment, and a fresh variable counter
    var typeEnv = TypeEnv()
    var counter = -1
    
    // Type checking errors
    enum TypeError : Error {
        case UnificationFail(MonoType, MonoType)
        case InfiniteType(TVar, MonoType)
        case UnboundedVariable(String)
        case UnimplementedError
    }
    
    // monomorphic types
    enum MonoType : Equatable {
        case TVar(TVar)
        case TCon(String)
        indirect case TArr(MonoType, MonoType)
    }
    
    // Declarations of built-in types that correspond to literals
    let typeFloat : MonoType = MonoType.TVar("Float")
    let typeInt : MonoType = MonoType.TVar("Int")
    let typeString = MonoType.TVar("String")
    
    // polymorphic type schemes
    class Scheme {
        var tyVars : [TVar]
        var ty : MonoType
        
        init(tyVars : [TVar], ty : MonoType) {
            self.tyVars = tyVars
            self.ty = ty
        }
    }
    
    func extend(_ typeEnv : TypeEnv, _ varname : Var, _ scheme : Scheme) -> TypeEnv {
        var newTypeEnv = typeEnv
        newTypeEnv[varname] = scheme
        return newTypeEnv
    }
    
    // Substitution of type variables to types
    typealias Subst = [TVar : MonoType]
    
    let nullSubst = Subst()
    
    // Apply substitution `s1` then `s2`
    func compose(_ s1 : Subst, _ s2 : Subst) -> Subst {
        var newSubst = s1
        let s2App = s2.mapValues( { (tyVar : MonoType) -> MonoType in return apply(s1, with : tyVar) })
        for (k, v) in s2App {
            newSubst[k] = v
        }
        return newSubst
    }
    
    // Apply a substitution to a monotype
    // For type variables, if a substitution does not exist, return
    // the type variable itself.
    func apply(_ s : Subst, with tyVar : MonoType) -> MonoType {
        switch tyVar {
        case .TCon(let tyConstructor):
            return MonoType.TCon(tyConstructor)
        case .TVar(let tyName):
            if let substituted = s[tyName] {
                return substituted
            }
            else {
                return MonoType.TVar(tyName)
            }
        case .TArr(let t1, let t2):
            return MonoType.TArr(apply(s, with: t1), apply(s, with: t2))
        }
    }
    
    func apply(_ s : Subst, with scheme : Scheme) -> Scheme {
        // Remove variable capturing from the scheme
        var newSubst = s
        for tvarname in scheme.tyVars {
            newSubst.removeValue(forKey: tvarname)
        }
        
        // Reapply fresh substitutions with the new context
        let tyRec = apply(s, with : scheme.ty)
        
        return Scheme(tyVars : scheme.tyVars, ty : tyRec)
    }
 
    func apply(_ s : Subst, with tEnv : TypeEnv) -> TypeEnv {
        var newTypeEnv = tEnv
        for (tyvar, scheme) in newTypeEnv {
            newTypeEnv[tyvar] = apply(s, with : scheme)
        }
        return newTypeEnv
    }
    
    func ftv(with tyVar : MonoType) -> Set<TVar> {
        switch tyVar {
        case .TCon( _):
            return []
        case .TVar(let a):
            return [a]
        case .TArr(let t1, let t2):
            return ftv(with: t1).union(ftv(with: t2))
        }
    }
    
    func ftv(with scheme : Scheme) -> Set<TVar> {
        return ftv(with : scheme.ty).subtracting(scheme.tyVars)
    }
    
    func ftv(with tEnv : TypeEnv) -> Set<TVar> {
        var ftvSet : Set<TVar> = []
        for sch in tEnv.values {
            ftvSet = ftvSet.union(ftv(with : sch))
        }
        return ftvSet
    }
    
    func fresh() -> MonoType {
        counter += 1
        return MonoType.TVar("v" + String(counter))
    }
    
    // Unification of two expressions under a substituion
    func unify(_ t1 : MonoType, _ t2 : MonoType) throws -> Subst {
        switch(t1, t2) {
        case (.TArr(let l1, let r1), .TArr(let l2, let r2)):
            let s1 = try unify(l1, l2)
            let s2 = try unify(apply(s1, with : r1), apply(s1, with : r2))
            return compose(s2, s1)
        case(.TVar(let a), let t):
            return try bind(a, t)
        case(let t, .TVar(let a)):
            return try bind(a, t)
        case(.TCon(let a), .TCon(let b)) where a == b:
            return nullSubst
        default:
            throw TypeError.UnificationFail(t1, t2)
        }
    }
        
    func bind(_ a : TVar, _ t : MonoType) throws -> Subst {
        if (t == MonoType.TVar(a)) {
            return nullSubst
        } else if (occursCheck(a, t)) {
            throw TypeError.InfiniteType(a, t)
        } else {
            return [a : t]
        }
    }
    
    func occursCheck(_ a : String, _ t : MonoType) -> Bool {
        return ftv(with : t).contains(a)
    }
    
    // Generalization and instantiation
    func instantiate(_ s : Scheme) -> MonoType {
        var subst = Subst()
        for oldVar in s.tyVars {
            let newVar = fresh()
            subst[oldVar] = newVar
        }
        return apply(subst, with : s.ty)
    }
    
    func generalize(_ tyEnv : TypeEnv, t : MonoType) -> Scheme {
        let tyVars = Array(ftv(with : t).subtracting(ftv(with : tyEnv)))
        return Scheme(tyVars: tyVars, ty: t)
    }
    
    // The main function: infer the type of an expression (AST node)
    func infer(_ expr : EINode) throws -> (Subst, MonoType) {
        switch expr {
        case _ as EIParser.FloatingPoint:
            return (nullSubst, typeFloat)
        case _ as EIParser.Integer:
            return (nullSubst, typeInt)
        default:
            throw TypeError.UnimplementedError
        }
    }
}
