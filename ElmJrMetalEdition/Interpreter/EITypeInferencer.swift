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
    // Type checker state
    var inferState: Infer
    var input: [EINode]
    var inputIndex : Int
    
    init(parsed : [EINode] = []) {
        input = parsed
        inferState = Infer()
        inputIndex = 0
    }
    
    func appendNode(parsed : [EINode]) {
        input += parsed
    }
    
    /* This EINode represents functions which can be recursive
        Additional constraints will be generated upon encountering this node
        This will be applied to declaration nodes that have a function body
     */
    class Fix: EINode {
        let body: EINode
        
        init(body: EINode) {
            self.body = body
        }
        
        // Don't care about displaying this as it should be invisible
        // to other parts of the compiler
        var description: String {
            return body.description
        }
    }
 
    
    
    // Stores type information of EINodes
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
            if let scheme = types[x] {
                return scheme
            } else {
                throw TypeError.VarNotInEnv
            }
        }
        
        var description : String {
            var s = ""
            for (v, scheme) in types {
                s += v + " : \(scheme)\n"
            }
            return s
        }
    }
    
    func showEnv() -> String {
        return inferState.typeEnv.description
    }
    
    // Data structure for providing fresh variable names in different contexts
    class VarSupply {
        // local to InferState
        var numberCounter : Int
        var alphaCounter : Int
        var noValueCounter : Int

        // global
        var globNumberCounter : Int
        var globAlphaCounter : Int
        
        init() {
            numberCounter = -1
            alphaCounter = -1
            noValueCounter = -1
            globNumberCounter = -1
            globAlphaCounter = 96
        }
        
        func resetGlobalState() {
            globNumberCounter = -1
            globAlphaCounter = 96
        }
        
        func globalFresh() -> MonoType {
            globAlphaCounter += 1
            if globAlphaCounter > 122 {
                return .TVar("v" + String(globAlphaCounter))
            }
            else {
                return .TVar(String(UnicodeScalar(alphaCounter)!))
            }
            
        }
        
        func globalFreshNumber() -> MonoType {
            globNumberCounter += 1
            return .TSuper("number", globNumberCounter)
        }
        
        func freshNoValue() -> MonoType {
            noValueCounter += 1
            return .TNoValue("internal_novalue_v_" + String(noValueCounter))
        }
        
        func fresh() -> MonoType {
            alphaCounter += 1
            return .TVar("internal_v_" + String(alphaCounter))
        }
        
        func freshNumber() -> MonoType {
            numberCounter += 1
            return .TSuper("number", numberCounter)
        }
    }
    
    // Inference state - A type environment and a counter for fresh typevars
    class Infer {
        var typeEnv: TypeEnv
        var counter: Int
        var supply: VarSupply
        
        init() {
            typeEnv = TypeEnv()
            counter = 0
            supply = VarSupply()
        }
        
    }
    
    // Type checking errors
    enum TypeError: Error {
        case UnificationFail(MonoType, MonoType)
        case InfiniteType(TVar, MonoType)
        case UnboundedVariable(String)
        case NotInScopeTyVar
        case VarNotInEnv
        case UnimplementedError(EINode)
    }
    
    typealias Constraint = (MonoType, MonoType)
    
    // Declarations of built-in types that correspond to literals
    let typeFloat = MonoType.TCon("Float")
    let typeInt = MonoType.TCon("Int")
    let typeString = MonoType.TCon("String")
    let typeBool = MonoType.TCon("Bool")
        
    // The collection of type constraints
    /* let superTypes: [MonoType] =
        [MonoType.TVar("number"),
         MonoType.TVar("appendable"),
         MonoType.TVar("comparable"),
         MonoType.TVar("compappend")]
    */
    
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
    
    /*
     Substitutable instances define the `apply` and `ftv` functions:
     - `apply` takes a substitution and applies it to the given data
     - `ftv` queries the set of free variables in an expression
     */
    
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
        case .TSuper(let supName, let inst):
            if let substituted = s[supName + String(inst)] {
                return substituted
            } else {
                return MonoType.TSuper(supName, inst)
            }
        case .TArr(let t1, let t2):
            return MonoType.TArr(apply(s, with: t1), apply(s, with: t2))
        case .CustomType(let tyName, let types):
            return MonoType.CustomType(tyName, types.map{ apply(s, with: $0) })
        case .TupleType(let t1, let t2, let t3):
            return MonoType.TupleType(apply(s, with: t1), apply(s, with: t2), (t3 != nil ? apply(s, with: t3!) : nil))
        case .TNoValue(let id):
            return .TNoValue(id)
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
        case .TSuper:
            return []
        case .TVar(let a):
            return [a]
        case .TArr(let t1, let t2):
            return ftv(with: t1).union(ftv(with: t2))
        case .CustomType( _, let tys):
            return Set(tys.flatMap(ftv))
        case .TupleType(let a, let b, let c):
            if let unC = c {
                return Set([a,b,unC].flatMap(ftv))
            } else {
                return Set([a,b].flatMap(ftv))
            }
        case .TNoValue:
            return []
        }
    }
    
    func ftv(with scheme: Scheme) -> Set<TVar> {
        return ftv(with: scheme.ty).subtracting(scheme.tyVars)
    }
    
    func ftvTyEnv() -> Set<TVar> {
        var ftvSet: Set<TVar> = []
        for sch in inferState.typeEnv.types.values {
            ftvSet = ftvSet.union(ftv(with: sch))
        }
        return ftvSet
    }
    
    func ftvTyEnv(with tyEnv : TypeEnv) -> Set<TVar> {
        var ftvSet: Set<TVar> = []
        for sch in tyEnv.types.values {
            ftvSet = ftvSet.union(ftv(with: sch))
        }
        return ftvSet
    }
    
    /*
     INFERENCE
     */
    
    func inferNext() {
        do {
            let expr = input[inputIndex]
            inputIndex += 1
            switch expr {
            case let declr as EIAST.Declaration :
                let ty: Scheme
                if let fn = declr.body as? EIAST.Function {
                    ty = try inferExpr(Fix(body: EIAST.Function(parameter: declr.name, body: fn)))
                } else {
                    ty = try inferExpr(declr.body)
                }
                inferState.typeEnv.extend(declr.name, ty)
            // Algebraic Data Types
            case let tyDef as EIAST.TypeDefinition:
                for consDef in tyDef.constructors {
                    var consTy = MonoType.CustomType(tyDef.typeName, tyDef.typeVars.map{MonoType.TVar($0)})
                    for tyParam in consDef.typeParameters.reversed() {
                        if let v = ftv(with: tyParam).subtracting(Set(tyDef.typeVars)).first {
                            throw TypeError.UnboundedVariable(v)
                        }
                        consTy = tyParam => consTy
                    }
                    inferState.typeEnv.extend(consDef.constructorName, Scheme(tyVars: tyDef.typeVars, ty: consTy))
                }
                // print(inferState.typeEnv.description)
            default:
                let ty = try inferExpr(expr)
                inferState.typeEnv.extend(expr.description, ty)
            }
        } catch TypeError.UnificationFail(let t1, let t2) {
                print("Unification fail: \(t1) and \(t2)")
        } catch TypeError.InfiniteType(let tvar, let t) {
                print("Occurs check: \(tvar) with \(t)")
        } catch TypeError.UnboundedVariable(let s) {
                print("Unbounded variable: " + s)
        } catch TypeError.NotInScopeTyVar {
                print("Type variable not in scope")
        } catch {
                print("A feature was not implemented")
        }
    }
    
    func inferAll() throws {
        for _ in input[inputIndex...] {
            inferNext()
        }
        inputIndex = input.count
    }

    func inferExpr(_ expr: EINode) throws -> Scheme {
        var (ty, cs) = try infer(expr)
        let subst = try runSolve(&cs)
        return try closeOver(apply(subst, with: ty))
    }
    
    func closeOver(_ ty: MonoType) throws -> Scheme {
        return try normalize(generalize(ty))
    }
    
    func inEnv(_ x: Var, _ s: Scheme, _ expr: EINode) throws -> (MonoType, [Constraint]) {
        let saveEnv = inferState.typeEnv
        inferState.typeEnv.remove(x)
        inferState.typeEnv.extend(x, s)
        let tyLoc = try infer(expr)
        inferState.typeEnv = saveEnv
        return tyLoc
    }

    func lookupEnv(x: Var) throws -> MonoType {
        if let s = inferState.typeEnv.types[x] {
            return instantiate(s)
        } else {
            throw TypeError.UnboundedVariable(x)
        }
    }
    
    // Generalization and instantiation
    func instantiate(_ s: Scheme) -> MonoType {
        var subst = Subst()
        for oldVar in s.tyVars {
            let newVar = inferState.supply.fresh()
            subst[oldVar] = newVar
        }
        return apply(subst, with: s.ty)
    }
    
    func generalize(_ t: MonoType) -> Scheme {
        let tyVars = Array(ftv(with: t).subtracting(ftvTyEnv()))
        return Scheme(tyVars: tyVars, ty: t)
    }

    func generalize(_ tyEnv : TypeEnv, _ t : MonoType) -> Scheme {
        let tyVars = Array(ftv(with: t).subtracting(ftvTyEnv(with : tyEnv)))
        return Scheme(tyVars: tyVars, ty: t)
    }
    
    func ops(_ op: EIAST.BinaryOp.BinaryOpType) -> MonoType {
        switch op {
        case EIAST.BinaryOp.BinaryOpType.add,
             EIAST.BinaryOp.BinaryOpType.subtract,
             EIAST.BinaryOp.BinaryOpType.multiply,
             EIAST.BinaryOp.BinaryOpType.divide:
            let freshNum = inferState.supply.freshNumber()
            return freshNum => (freshNum => freshNum)
        case EIAST.BinaryOp.BinaryOpType.eq,
             EIAST.BinaryOp.BinaryOpType.ne,
             EIAST.BinaryOp.BinaryOpType.le,
             EIAST.BinaryOp.BinaryOpType.lt,
             EIAST.BinaryOp.BinaryOpType.ge,
             EIAST.BinaryOp.BinaryOpType.gt:
            let tv = inferState.supply.fresh()
            return tv => (tv => typeBool)
        case EIAST.BinaryOp.BinaryOpType.and,
             EIAST.BinaryOp.BinaryOpType.or:
            return typeBool => (typeBool => typeBool)
        default:
            // @Lucas I'm putting in a default case while I add new operators for now.
            // Feel free to remove this if you know a better way
            assert(false)
            return .TVar("a")
        }
    }
    
    func infer(_ expr: EINode) throws -> (MonoType, [Constraint]) {
        switch expr {
        // Since we don't know if standalone integers may be used as
        // part of a subexpression with floats, we infer the more general
        // type constraint "number"
        case let v as EIAST.Variable:
            return try (lookupEnv(x: v.name), [])
        case let f as EIAST.Function:
            let tv = inferState.supply.fresh()
            let (t, c) = try inEnv(f.parameter, Scheme(tyVars: [], ty: tv), f.body)
            return (tv => t, c)
        case let fApp as EIAST.FunctionApplication:
            let (t1, c1) = try infer(fApp.function)
            let (t2, c2) = try infer(fApp.argument)
            let tv = inferState.supply.fresh()
            return (tv, c1 + c2 + [(t1, t2 => tv)])
        case let fix as Fix:
            let (t1, c1) = try infer(fix.body)
            let tv = inferState.supply.fresh()
            return (tv, c1 + [(tv => tv, t1)])
        case _ as EIAST.Integer:
            let freshNum = inferState.supply.freshNumber()
            return (freshNum, [])
        case _ as EIAST.FloatingPoint:
            return (MonoType.TCon("Float"), [])
        case _ as EIAST.Boolean:
            return (MonoType.TCon("Bool"), [])
        case _ as EIAST.Str:
            return (MonoType.TCon("String"), [])
        case let e as EIAST.BinaryOp:
            let (t1, c1) = try infer(e.leftOperand)
            let (t2, c2) = try infer(e.rightOperand)
            let tv = inferState.supply.fresh()
            let u1 = t1 => (t2 => tv)
            let u2 = ops(e.type)
            return (tv, c1 + c2 + [(u1, u2)])
        case let e as EIAST.IfElse:
            let inferConds = try e.conditions.map(infer)
            let inferBranches = try e.branches.map(infer)
            let branchConstraints: [Constraint] =
                (0..<inferBranches.count - 1)
                    .map { (inferBranches[$0].0,
                            inferBranches[$0 + 1].0) }
            let condConstraints: [Constraint] =
                inferConds.map { ($0.0, MonoType.TCon("Bool")) }
            let otherConstraints: [Constraint] =
                inferConds.flatMap { $0.1 } + inferBranches.flatMap { $0.1 }
            return (inferBranches[0].0,
                    otherConstraints + branchConstraints + condConstraints)
        case let tup as EIAST.Tuple:
            let (t1, c1) = try infer(tup.v1)
            let (t2, c2) = try infer(tup.v2)
            if let arg3 = tup.v3 {
                let (t3, c3) = try infer(arg3)
                return (MonoType.TupleType(t1, t2, t3), c1 + c2 + c3)
            } else {
                return (MonoType.TupleType(t1, t2, nil), c1 + c2)
            }
        case let list as EIAST.List:
            var ts : [MonoType] = []
            var cs : [Constraint] = []
            for elem in list.items {
                let (t, c) = try infer(elem)
                ts.append(t)
                cs += c
            }
            let tv = inferState.supply.fresh()
            let listConstraints : [Constraint] =
                ts.count == 0 ? [] : 
                (0..<ts.count - 1)
                    .map { (ts[$0],
                            ts[$0 + 1]) }
            let unifyListTy = ts.count == 0 ? [] : [(tv, ts[0])]
            return (MonoType.CustomType("List", [tv]), cs + listConstraints + unifyListTy)
        case _ as EIAST.NoValue:
            let ntv = inferState.supply.freshNoValue()
            return (ntv, [])
        default:
            throw TypeError.UnimplementedError(expr)
        }
    }
    
    func normalize(_ s: Scheme) throws -> Scheme {
        // Refresh the state of supply of global type variables
        inferState.supply.resetGlobalState()
        
        func fv(_ m: MonoType) -> [TVar] {
            switch m {
            // no free variables in type constraints
            case .TSuper:
                return []
            case .TVar(let a):
                return [a]
            case .TCon:
                return []
            case .TArr(let a, let b):
                return fv(a) + fv(b)
            case .CustomType(_, let tys):
                return tys.flatMap(fv)
            case .TupleType(let a, let b, let c):
                if let unC = c {
                    return [a,b,unC].flatMap(fv)
                } else {
                    return [a,b].flatMap(fv)
                }
            case .TNoValue:
                return []
            }
        }
        
        func superVars(_ m : MonoType) -> [TVar] {
            switch m {
            case .TSuper(let a, let n):
                return [a + String(n)]
            case .TArr(let a, let b):
                return superVars(a) + superVars(b)
            default:
                return []
            }
        }
        
        var freshVars: [MonoType] = []
        let fvs: [TVar] = Array(Set(fv(s.ty)))
        for _ in 0..<fvs.count {
            freshVars.append(inferState.supply.globalFresh())
        }
        
        // This has to be reworked to account for all type constraints
        var freshNumVars: [MonoType] = []
        let numVars: [TVar] = Array(Set(superVars(s.ty)))
        for _ in 0..<numVars.count {
            freshNumVars.append(inferState.supply.globalFreshNumber())
        }
        
        assert(fvs.count + freshNumVars.count ==
                freshVars.count + freshNumVars.count)
        let ord = zip(fvs + numVars, freshVars + freshNumVars)
        
        func normtype(_ m: MonoType) throws -> MonoType {
            switch m {
            // do NOT normalize type constraints
            case .TSuper(let a, let n):
                if let x = Dictionary(uniqueKeysWithValues: ord)[a + String(n)] {
                    return x
                } else {
                    throw TypeError.NotInScopeTyVar
                }
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
            case .CustomType(let name, let tys):
                return .CustomType(name, try tys.map(normtype))
            case .TupleType(let a, let b, let c):
                if let unC = c {
                    return .TupleType(try normtype(a), try normtype(b), try normtype(unC))
                } else {
                    return .TupleType(try normtype(a), try normtype(b), nil)
                }
            case .TNoValue(let nv):
                return .TNoValue(nv)
            }
        }
        
        var extracted: [TVar] = []
        for case MonoType.TVar(let t) in freshVars {
            extracted.append(t)
        }
        return Scheme(tyVars: extracted, ty: try normtype(s.ty))
    }

    /*
     Constraint Solver
     */
    
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
    
    func runSolve(_ cs: inout [Constraint]) throws -> Subst {
        return try solver(nullSubst, &cs)
    }
    
    // Unification of two expressions under a substitution
    func unify(_ t1: MonoType, _ t2: MonoType) throws -> Subst {
        switch (t1, t2) {
        case(let a, let b) where a == b:
            return nullSubst
        /* Handle NOVALUE nodes here: If I see a constraint on a NoValue type,
            there will be two cases:
            - NoValue not in the type-env: Just add it into the TypeEnv
            - It is in the TypeEnv: Retreive its type, perform unification, then
              perform the substitution on the NoValue type in the table
        */
        case(.TNoValue(let ident), let t):
            do {
                let scheme = try inferState.typeEnv.lookup(ident)
                let subst = try unify(scheme.ty, t)
                let newScheme = try closeOver(apply(subst, with: scheme.ty))
                inferState.typeEnv.extend(ident, newScheme)
                return nullSubst
            } catch TypeError.VarNotInEnv {
                inferState.typeEnv.extend(ident, Scheme(tyVars: [], ty: t))
                return nullSubst
            }
        // unify type constraints
        case(.TSuper(let a, let n), .TSuper(let b, _))
            where a == b:
            return try bind(a + String(n), t2)
        // Downcast Number supertype when encountering Floats
        case(.TSuper(let a, let inst), .TCon(let x))
            where a == "number" && x == "Float":
            return try bind(a + String(inst), t2)
        case(.TCon(let x), .TSuper(let a, let inst))
            where a == "number" && x == "Float":
            return try bind(a + String(inst), t1)
        // Unify type variables in algebraic data types
        case(.CustomType(let a, let vars1), .CustomType(let b, let vars2))
            where a == b && vars1.count == vars2.count:
            return try zip(vars1, vars2).map(unify).reduce(nullSubst, compose)
        // Recursively unify arrow types
        case (.TArr(let l1, let r1), .TArr(let l2, let r2)):
            let s1 = try unify(l1, l2)
            let s2 = try unify(apply(s1, with: r1), apply(s1, with: r2))
            return compose(s2, s1)
        // Bind type variables
        case(.TVar(let a), let t):
            return try bind(a, t)
        case(let t, .TVar(let a)):
            return try bind(a, t)
        // Recursively unify tuple types
        case(.TupleType(let t1, let t2, let mt3), .TupleType(let u1, let u2, let mu3)):
            let s1 = try unify(t1, u1)
            let s2 = try unify(t2, u2)
            var s3 = nullSubst
            if let m3 = mt3, let u3 = mu3 {
                s3 = try unify(m3, u3)
            }
            return compose(s3, compose(s2, s1))
        default:
            throw TypeError.UnificationFail(t1, t2)
        }
    }
        
    func bind(_ a: TVar, _ t: MonoType) throws -> Subst {
        if t == MonoType.TVar(a) {
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
        
    func solver(_ su: Subst, _ cs: inout [Constraint]) throws -> Subst {
        if cs.count == 0 {
            return su
        }
        let (t1, t2) = cs.removeLast()
        let su1 = try unify(t1, t2)
        var cs2 = apply(su1, with: cs)
        return try solver(compose(su1, su), &cs2)
    }
    
    /*
     Type Signature Checking
     */
    
    class TySig {
        var tyEnv : TypeEnv
        var bindings : [TVar : MonoType]
        var revBindings : [TVar : MonoType]
        init(_ argTyEnv : TypeEnv) {
            tyEnv = argTyEnv
            bindings = [TVar : MonoType]()
            revBindings = [TVar : MonoType]()
        }
        
        /**
        Checking type signatures involve the following process
         1. Create a mapping for all type variables and super types in both directions, as the equality is symmetric.
         2. Use the mapping to check for consistency.
         
         */
        func tcTySigTop(_ given : MonoType, _ declr : Var) throws -> Bool {
            let actual = try tyEnv.lookup(declr).ty
            assignMapping(given, actual)
            return tcTySig(given, actual)
        }
        
        func assignMapping(_ given : MonoType, _ actual : MonoType) {
            switch (given, actual) {
            case (.TVar(let v1), .TVar(let v2)):
                bindings[v2] = given
                revBindings[v1] = actual
            case (.TSuper(let s1, let n1), .TSuper(let s2, let n2)):
                let superVar2 = s2 + (n2 == 0 ? "" : String(n2))
                let superVar1 = s1 + (n1 == 0 ? "" : String(n1))
                bindings[superVar2] = given
                revBindings[superVar1] = actual
            case(.CustomType(_, let tys1), .CustomType(_, let tys2)):
                for (t1, t2) in zip(tys1, tys2) {
                    assignMapping(t1, t2)
                }
            case (.TArr(let a1, let b1), .TArr(let a2, let b2)):
                assignMapping(a1, a2)
                assignMapping(b1, b2)
            case (.TupleType(let a1, let b1, let c1), .TupleType(let a2, let b2, let c2)):
                assignMapping(a1, a2)
                assignMapping(b1, b2)
                if let unc1 = c1, let unc2 = c2 {
                    assignMapping(unc1, unc2)
                }
            default:
                return
            }
        }
        
        func tcTySig(_ given : MonoType, _ actual : MonoType) -> Bool {
            switch (given, actual) {
            case (.TCon(let con1), .TCon(let con2)):
                return con1 == con2
            case (.TVar(let v1), .TVar(let v2)):
                if case let .TVar(bind) = bindings[v2], case let .TVar(revBind) = revBindings[v1] {
                    return bind == v1 && revBind == v2
                } else {
                    return false
                }
            case (.TArr(let a1, let b1), .TArr(let a2, let b2)):
                return tcTySig(a1, a2) && tcTySig(b1, b2)
            case (.TSuper(let s1, let n1), .TSuper(let s2, let n2)):
                let superVar2 = s2 + (n2 == 0 ? "" : String(n2))
                let superVar1 = s1 + (n1 == 0 ? "" : String(n1))
                if case let .TSuper(s, n) = bindings[superVar2], case let .TSuper(rs, rn) = revBindings[superVar1] {
                    return given == .TSuper(s, n) && actual == .TSuper(rs, rn)
                } else {
                    return false
                }
            case (.CustomType(let s1, let tys1), .CustomType(let s2, let tys2)):
                if (tys1.count != tys2.count || s1 != s2) { return false }
                var isEqual = true
                for (t1, t2) in zip(tys1, tys2) {
                    isEqual = isEqual && tcTySig(t1, t2)
                }
                return isEqual
            case (.TupleType(let a1, let b1, let c1), .TupleType(let a2, let b2, let c2)):
                if let unc1 = c1, let unc2 = c2 {
                    return tcTySig(a1, a2) && tcTySig(b1, b2) && tcTySig(unc1, unc2)
                } else {
                    return tcTySig(a1, a2) && tcTySig(b1, b2)
                }
            default:
                return false
            }
        }
    }
    
    // NoValue query function
    func getNoValue(x : String) throws -> MonoType {
        let scheme = try inferState.typeEnv.lookup(x)
        return scheme.ty
    }
}
