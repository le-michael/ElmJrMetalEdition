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
    
    var inferState : Infer
    var input : [Var : EINode]
    
    init (parsed : [Var : EINode]) {
        input = parsed
        inferState = Infer()
    }
    
    class TypeEnv {
        var types : [Var : Scheme]
        
        init () {
            types = [Var : Scheme]()
        }
        
        func extend(_ x : Var, _ s : Scheme) {
            types[x] = s
        }
        
        func remove(_ v : Var) {
            types[v] = nil
        }
        
        func lookup(_ x : Var) throws -> Scheme {
            return types[x]!
        }
    }
    
    class Infer {
        var typeEnv : TypeEnv
        var counter : Int
        
        init() {
            typeEnv = TypeEnv()
            counter = -1
        }
        
        func fresh() -> MonoType {
            counter += 1
            return MonoType.TVar("v" + String(counter))
        }
    }
    
    
    func inEnv(_ x : Var,  _ s : Scheme, _ expr : EINode) throws -> (MonoType, [Constraint]) {
        let saveEnv = inferState.typeEnv
        inferState.typeEnv.remove(x)
        inferState.typeEnv.extend(x, s)
        let tyLoc = try infer(expr)
        typeEnv = saveEnv
        return tyLoc
    }

    func lookupEnv(x : Var) throws -> MonoType {
        if let s = inferState.typeEnv.types[x] {
            return instantiate(s)
        } else {
            throw TypeError.UnboundedVariable(x)
        }
    }
    
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
        case NotInScopeTyVar
        case UnimplementedError
    }
    
    // monomorphic types
    enum MonoType : Equatable, CustomStringConvertible {
        case TVar(TVar)
        case TCon(String)
        indirect case TArr(MonoType, MonoType)
        
        var description : String {
            switch self {
            case .TVar(let v):
                return v
            case .TCon(let con):
                return con
            case .TArr(let t1, let t2):
                return "\(t1.description) -> \(t2.description)"
            }
        }
    }
    
    lazy var superNumber = MonoType.TVar("number")
    
    typealias Constraint = (MonoType, MonoType)
    
    // Declarations of built-in types that correspond to literals
    let typeFloat : MonoType = MonoType.TVar("Float")
    let typeInt : MonoType = MonoType.TVar("Int")
    let typeString = MonoType.TVar("String")
    
    // polymorphic type schemes
    class Scheme : CustomStringConvertible {
        var tyVars : [TVar]
        var ty : MonoType
        
        init(tyVars : [TVar], ty : MonoType) {
            self.tyVars = tyVars
            self.ty = ty
        }
        
        lazy var description = "\(ty.description)"
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
    
    func apply(_ s : Subst, with c : Constraint) -> Constraint {
        let (t1, t2) = c
        return (apply(s, with : t1), apply(s, with : t2))
    }
    
    func apply(_ s : Subst, with cs : [Constraint]) -> [Constraint] {
        return cs.map { apply(s, with : $0 ) } 
    }
    
    func apply(_ s : Subst, with tEnv : TypeEnv) {
        for (tyvar, scheme) in tEnv.types {
            tEnv.types[tyvar] = apply(s, with : scheme)
        }
    }
    
    func ftv(with tyVar : MonoType) -> Set<TVar> {
        switch tyVar {
        case .TCon( _):
            return []
        // TODO: Are type constraints ftvs?
        case .TVar(let a) where a == "number":
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
    
    func ftvTyEnv() -> Set<TVar> {
        var ftvSet : Set<TVar> = []
        for sch in typeEnv.types.values {
            ftvSet = ftvSet.union(ftv(with : sch))
        }
        return ftvSet
    }
    
    // Unification of two expressions under a substituion
    func unify(_ t1 : MonoType, _ t2 : MonoType) throws -> Subst {
        switch(t1, t2) {
        // Downcast Number supertype when encountering Floats
        case(.TVar(let a), .TCon(let x))
                where a == "number" && x == "Float":
            return try bind(a, t2)
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
        // This may be redundant
        } else if t == superNumber {
            return [a : superNumber]
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
            let newVar = inferState.fresh()
            subst[oldVar] = newVar
        }
        return apply(subst, with : s.ty)
    }
    
    func generalize(_ t : MonoType) -> Scheme {
        let tyVars = Array(ftv(with : t).subtracting(ftvTyEnv()))
        return Scheme(tyVars: tyVars, ty: t)
    }
    
    func ops(_ op : EIAST.BinaryOp.BinaryOpType) -> MonoType {
        switch op {
        case EIAST.BinaryOp.BinaryOpType.add,
             EIAST.BinaryOp.BinaryOpType.subtract,
             EIAST.BinaryOp.BinaryOpType.multiply,
             EIAST.BinaryOp.BinaryOpType.divide:
            return MonoType.TArr(superNumber,
                   MonoType.TArr(superNumber, superNumber))
        default:
            // @Lucas I'm putting in a default case while I add new operators for now.
            // Feel free to remove this if you know a better way
            assert(false)
            return MonoType.TArr(superNumber,
                   MonoType.TArr(superNumber, superNumber))
        }
    }
    
    func infer(_ expr : EINode) throws -> (MonoType, [Constraint]) {
        switch expr {
        // Since we don't know if standalone integers may be used as
        // part of a subexpression with floats, we infer the more general
        // type constraint "number"
        case _ as EIAST.Integer:
            return (MonoType.TVar("number"), [])
        case _ as EIAST.FloatingPoint:
            return (MonoType.TCon("Float"), [])
        case let e as EIAST.BinaryOp:
            let (t1, c1) = try infer(e.leftOperand)
            let (t2, c2) = try infer(e.rightOperand)
            let tv = inferState.fresh()
            let u1 = MonoType.TArr(t1, MonoType.TArr(t2, tv))
            let u2 = ops(e.type)
            return (tv, c1 + c2 + [(u1, u2)])
        default:
            throw TypeError.UnimplementedError
        }
    }
    
    func inferExpr(_ expr : EINode) throws -> Scheme {
        var (ty, cs) = try infer(expr)
        let subst = try runSolve(&cs)
        return try closeOver(apply(subst, with : ty))
    }
    
    func inferTop() throws -> TypeEnv {
        for (x, expr) in input {
            let ty = try inferExpr(expr)
            inferState.typeEnv.extend(x, ty)
        }
        return inferState.typeEnv
    }
    
    func closeOver(_ ty : MonoType) throws -> Scheme {
        return try normalize(generalize(ty))
    }
    
    func normalize(_ s : Scheme) throws -> Scheme {
        func fv(_ m : MonoType) -> [TVar] {
            switch m {
            // no free variables in type constraints
            case .TVar(let a) where a == "number":
                return []
            case .TVar(let a):
                return [a]
            case .TCon(_):
                return []
            case .TArr(let a, let b):
                return fv(a) + fv(b)
            }
        }
        
        var freshVars : [MonoType] = []
        let fvs : [TVar] = Array(Set(fv(s.ty)))
        for _ in 0..<fvs.count {
            freshVars.append(inferState.fresh())
        }
        let ord = zip(fvs, freshVars)
        
        func normtype(_ m : MonoType) throws -> MonoType {
            switch m {
            // do NOT normalize type constraints
            case .TVar(let a)
                    where a == "number":
                return superNumber
            case .TVar(let a):
                if let x = Dictionary(uniqueKeysWithValues: ord)[a] {
                    return x
                } else {
                    throw TypeError.NotInScopeTyVar
                }
            case .TCon(let a):
                return .TCon(a)
            case .TArr(let a, let b):
                return .TArr(try normtype(a), try normtype(b))
            }
        }
        
        var extracted : [TVar] = []
        for case let MonoType.TVar(t) in freshVars {
            extracted.append(t)
        }
        return Scheme(tyVars: extracted, ty: try normtype(s.ty))
    }
    
    func solver(_ su : Subst, _ cs : inout [Constraint]) throws -> Subst {
        if cs.count == 0 {
            return su
        }
        let (t1, t2) = cs.removeLast()
        let su1 = try unify(t1, t2)
        var cs2 = apply(su1, with : cs)
        return try solver(compose(su1, su), &cs2)
    }
    
    func runSolve(_ cs : inout [Constraint]) throws -> Subst {
        return try solver(nullSubst, &cs)
    }
    
    func showEnv(_ x : String) throws -> String {
        return try inferState.typeEnv.lookup(x).description
    }
}
