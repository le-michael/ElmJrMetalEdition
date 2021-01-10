//
//  EITypeInferencer.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-06.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol Substitutable {}
infix operator =>

class EITypeInferencer {
    var inferState: Infer
    var input: [EINode]
    
    init(parsed: [EINode]) {
        input = parsed
        inferState = Infer()
    }
    
    class TypeEnv {
        var types: [Var: Scheme]
        
        init() {
            types = [Var: Scheme]()
        }
        
        func extend(_ x: Var, _ s: Scheme) {
            types[x] = s
        }
        
        func remove(_ v: Var) {
            types[v] = nil
        }
        
        func lookup(_ x: Var) throws -> Scheme {
            return types[x]!
        }
    }
    
    class Infer {
        var typeEnv: TypeEnv
        var counter: Int
        
        init() {
            typeEnv = TypeEnv()
            counter = -1
        }
        
        func fresh() -> MonoType {
            counter += 1
            return MonoType.TVar("v" + String(counter))
        }
    }
    
    func inEnv(_ x: Var, _ s: Scheme, _ expr: EINode) throws -> (MonoType, [Constraint]) {
        let saveEnv = inferState.typeEnv
        inferState.typeEnv.remove(x)
        inferState.typeEnv.extend(x, s)
        let tyLoc = try infer(expr)
        typeEnv = saveEnv
        return tyLoc
    }

    func lookupEnv(x: Var) throws -> MonoType {
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
    enum TypeError: Error {
        case UnificationFail(MonoType, MonoType)
        case InfiniteType(TVar, MonoType)
        case UnboundedVariable(String)
        case NotInScopeTyVar
        case UnimplementedError(EINode)
    }
    
    // monomorphic types
    enum MonoType: Equatable, CustomStringConvertible {
        case TVar(TVar)
        case TCon(String)
        indirect case TArr(MonoType, MonoType)
        
        static func => (left : MonoType, right : MonoType) -> MonoType {
            return TArr(left, right)
        }
        
        
        var description: String {
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
    
    typealias Constraint = (MonoType, MonoType)
    
    // Declarations of built-in types that correspond to literals
    let typeFloat = MonoType.TCon("Float")
    let typeInt = MonoType.TCon("Int")
    let typeString = MonoType.TCon("String")
    let typeBool = MonoType.TCon("Bool")
    
    // Declaration of type constraints
    let superNumber = MonoType.TVar("number")
    
    // The collection of type constraints
    let superTypes : [MonoType] =
        [ MonoType.TVar("number")
          , MonoType.TVar("appendable")
          , MonoType.TVar("comparable")
          , MonoType.TVar("compappend")
        ]
    
    // polymorphic type schemes
    class Scheme: CustomStringConvertible {
        var tyVars: [TVar]
        var ty: MonoType
        
        init(tyVars: [TVar], ty: MonoType) {
            self.tyVars = tyVars
            self.ty = ty
        }
        
        lazy var description = "\(ty.description)"
    }
    
    // Substitution of type variables to types
    typealias Subst = [TVar: MonoType]
    
    let nullSubst = Subst()
    
    // Apply substitution `s1` then `s2`
    func compose(_ s1: Subst, _ s2: Subst) -> Subst {
        var newSubst = s1
        let s2App = s2.mapValues { (tyVar: MonoType) -> MonoType in apply(s1, with: tyVar) }
        for (k, v) in s2App {
            newSubst[k] = v
        }
        return newSubst
    }
    
    // Apply a substitution to a monotype
    // For type variables, if a substitution does not exist, return
    // the type variable itself.
    func apply(_ s: Subst, with tyVar: MonoType) -> MonoType {
        switch tyVar {
        case .TCon(let tyConstructor):
            return MonoType.TCon(tyConstructor)
        case .TVar(let tyName):
            if let substituted = s[tyName] {
                return substituted
            } else {
                return MonoType.TVar(tyName)
            }
        case .TArr(let t1, let t2):
            return MonoType.TArr(apply(s, with: t1), apply(s, with: t2))
        }
    }
    
    func apply(_ s: Subst, with scheme: Scheme) -> Scheme {
        // Remove variable capturing from the scheme
        var newSubst = s
        for tvarname in scheme.tyVars {
            newSubst.removeValue(forKey: tvarname)
        }
        
        // Reapply fresh substitutions with the new context
        let tyRec = apply(s, with: scheme.ty)
        
        return Scheme(tyVars: scheme.tyVars, ty: tyRec)
    }
    
    func apply(_ s: Subst, with c: Constraint) -> Constraint {
        let (t1, t2) = c
        return (apply(s, with: t1), apply(s, with: t2))
    }
    
    func apply(_ s: Subst, with cs: [Constraint]) -> [Constraint] {
        return cs.map { apply(s, with: $0) }
    }
    
    func apply(_ s: Subst, with tEnv: TypeEnv) {
        for (tyvar, scheme) in tEnv.types {
            tEnv.types[tyvar] = apply(s, with: scheme)
        }
    }
    
    func ftv(with tyVar: MonoType) -> Set<TVar> {
        switch tyVar {
        case .TCon:
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
    
    func ftv(with scheme: Scheme) -> Set<TVar> {
        return ftv(with: scheme.ty).subtracting(scheme.tyVars)
    }
    
    func ftvTyEnv() -> Set<TVar> {
        var ftvSet: Set<TVar> = []
        for sch in typeEnv.types.values {
            ftvSet = ftvSet.union(ftv(with: sch))
        }
        return ftvSet
    }
    
    // Unification of two expressions under a substituion
    func unify(_ t1: MonoType, _ t2: MonoType) throws -> Subst {
        switch (t1, t2) {
        case(let a, let b) where a == b:
            return nullSubst
        // Downcast Number supertype when encountering Floats
        case(.TVar(let a), .TCon(let x))
            where a == "number" && x == "Float":
            return try bind(a, t2)
        case(.TCon(let x), .TVar(let a))
            where a == "number" && x == "Float":
            return try bind(a, t1)
        case (.TArr(let l1, let r1), .TArr(let l2, let r2)):
            let s1 = try unify(l1, l2)
            let s2 = try unify(apply(s1, with: r1), apply(s1, with: r2))
            return compose(s2, s1)
        case(.TVar(let a), let t)
            where !superTypes.contains(t1):
            return try bind(a, t)
        case(let t, .TVar(let a))
            where !superTypes.contains(t2):
            return try bind(a, t)
        default:
            throw TypeError.UnificationFail(t1, t2)
        }
    }
        
    func bind(_ a: TVar, _ t: MonoType) throws -> Subst {
        if superTypes.contains(t) {
            return [a : t]
        } else if t == MonoType.TVar(a) {
            return nullSubst
        } else if occursCheck(a, t) {
            throw TypeError.InfiniteType(a, t)
        } else {
            return [a: t]
        }
    }
    
    func occursCheck(_ a: String, _ t: MonoType) -> Bool {
        return ftv(with: t).contains(a)
    }
    
    // Generalization and instantiation
    func instantiate(_ s: Scheme) -> MonoType {
        var subst = Subst()
        for oldVar in s.tyVars {
            let newVar = inferState.fresh()
            subst[oldVar] = newVar
        }
        return apply(subst, with: s.ty)
    }
    
    func generalize(_ t: MonoType) -> Scheme {
        let tyVars = Array(ftv(with: t).subtracting(ftvTyEnv()))
        return Scheme(tyVars: tyVars, ty: t)
    }
    
    func ops(_ op: EIParser.BinaryOp.BinaryOpType) -> MonoType {
        switch op {
        case EIParser.BinaryOp.BinaryOpType.add,
             EIParser.BinaryOp.BinaryOpType.subtract,
             EIParser.BinaryOp.BinaryOpType.multiply,
             EIParser.BinaryOp.BinaryOpType.divide:
            return superNumber => (superNumber => superNumber)
        case EIParser.BinaryOp.BinaryOpType.eq,
             EIParser.BinaryOp.BinaryOpType.ne,
             EIParser.BinaryOp.BinaryOpType.le,
             EIParser.BinaryOp.BinaryOpType.lt,
             EIParser.BinaryOp.BinaryOpType.ge,
             EIParser.BinaryOp.BinaryOpType.gt:
            let tv = inferState.fresh()
            return tv => (tv => typeBool)
        case EIParser.BinaryOp.BinaryOpType.and,
             EIParser.BinaryOp.BinaryOpType.or:
            return typeBool => (typeBool => typeBool)
        default:
            // @Lucas I'm putting in a default case while I add new operators for now.
            // Feel free to remove this if you know a better way
            assert(false)
            return MonoType.TArr(superNumber,
                                 MonoType.TArr(superNumber, superNumber))
        }
    }
    
    func infer(_ expr: EINode) throws -> (MonoType, [Constraint]) {
        switch expr {
        // Since we don't know if standalone integers may be used as
        // part of a subexpression with floats, we infer the more general
        // type constraint "number"
        case _ as EIParser.Integer:
            return (MonoType.TVar("number"), [])
        case _ as EIParser.FloatingPoint:
            return (MonoType.TCon("Float"), [])
        case _ as EIParser.Boolean:
            return (MonoType.TCon("Bool"), [])
        case let e as EIParser.BinaryOp:
            let (t1, c1) = try infer(e.leftOperand)
            let (t2, c2) = try infer(e.rightOperand)
            let tv = inferState.fresh()
            let u1 = t1 => (t2 => tv)
            let u2 = ops(e.type)
            return (tv, c1 + c2 + [(u1, u2)])
        case let e as EIParser.IfElse:
            let inferConds = try e.conditions.map(infer)
            let inferBranches = try e.branches.map(infer)
            let branchConstraints : [Constraint] =
                (0..<inferBranches.count-1)
                    .map { (inferBranches[$0].0,
                            inferBranches[$0 + 1].0) }
            let condConstraints : [Constraint] =
                inferConds.map{ ($0.0, MonoType.TCon("Bool")) }
            let otherConstraints : [Constraint] =
                inferConds.flatMap{$0.1} + inferBranches.flatMap{$0.1}
            return (inferBranches[0].0,
                    otherConstraints + branchConstraints + condConstraints)
        // case let e as EIParser.Function:
        //    let tv = inferState.fresh()
            
        default:
            throw TypeError.UnimplementedError(expr)
        }
    }
    
    func inferExpr(_ expr: EINode) throws -> Scheme {
        var (ty, cs) = try infer(expr)
        let subst = try runSolve(&cs)
        return try closeOver(apply(subst, with: ty))
    }
    
    func inferTop() throws -> TypeEnv {
        for expr in input {
            let ty = try inferExpr(expr)
            if let function = expr as? EIParser.Function {
                inferState.typeEnv.extend(function.name, ty)
            } else {
                inferState.typeEnv.extend(expr.description, ty)
            }
        }
        return inferState.typeEnv
    }
    
    func closeOver(_ ty: MonoType) throws -> Scheme {
        return try normalize(generalize(ty))
    }
    
    func normalize(_ s: Scheme) throws -> Scheme {
        func fv(_ m: MonoType) -> [TVar] {
            switch m {
            // no free variables in type constraints
            case .TVar(let a) where a == "number":
                return []
            case .TVar(let a):
                return [a]
            case .TCon:
                return []
            case .TArr(let a, let b):
                return fv(a) + fv(b)
            }
        }
        
        var freshVars: [MonoType] = []
        let fvs: [TVar] = Array(Set(fv(s.ty)))
        for _ in 0..<fvs.count {
            freshVars.append(inferState.fresh())
        }
        let ord = zip(fvs, freshVars)
        
        func normtype(_ m: MonoType) throws -> MonoType {
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
        
        var extracted: [TVar] = []
        for case MonoType.TVar(let t) in freshVars {
            extracted.append(t)
        }
        return Scheme(tyVars: extracted, ty: try normtype(s.ty))
    }
    
    func solver(_ su: Subst, _ cs: inout [Constraint]) throws -> Subst {
        if cs.count == 0 {
            return su
        }
        let (t1, t2) = cs.removeLast()
        let su1 = try unify(t1, t2)
        var cs2 = apply(su1, with: cs)
        return try solver(compose(su1, su), &cs2)
    }
    
    func runSolve(_ cs: inout [Constraint]) throws -> Subst {
        return try solver(nullSubst, &cs)
    }
    
    func showEnv(_ x: String) throws -> String {
        return try inferState.typeEnv.lookup(x).description
    }
}
