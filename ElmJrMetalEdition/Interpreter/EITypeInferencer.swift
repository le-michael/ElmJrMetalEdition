//
//  EITypeInferencer.swift
//  ElmJrMetalEdition
//
//  Created by Lucas Dutton on 2020-12-06.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EITypeInferencer {
    
    init () {}
    
    // A type environment from variables to schemes
    typealias TypeEnv = [Var : Scheme]
    typealias Var = String
    
    var typeEnv = TypeEnv()
    
    // monomorphic types
    enum MonoType {
        case TVar(String)
        case TCon(String)
        indirect case TArr(MonoType, MonoType)
    }
    
    // polymorphic type schemes
    class Scheme {
        var tyVars : [String]
        var ty : MonoType
        
        init(tyVars : [String], ty : MonoType) {
            self.tyVars = tyVars
            self.ty = ty
        }
    }
    
    func extend(_ varname : Var, _ scheme : Scheme) {
        typeEnv[varname] = scheme
    }
    
    // Substitution of type variables to types
    typealias Subst = [String : MonoType]
    
    let nullSubst = Subst()
    
    // unimplemented
    func compose(_ s1 : Subst, _ s2 : Subst) -> Subst {
        return nullSubst
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
    
    func apply(_ s : inout Subst, with scheme : Scheme) -> Scheme {
        // Remove variable capturing from the scheme
        for tvarname in scheme.tyVars {
            s.removeValue(forKey: tvarname)
        }
        
        // Reapply fresh substitutions with the new context
        let tyRec = apply(s, with : scheme.ty)
        
        return Scheme(tyVars : scheme.tyVars, ty : tyRec)
    }
 
    func apply(_ s : inout Subst) {
        for (tyvar, scheme) in typeEnv {
            typeEnv[tyvar] = apply(&s, with : scheme)
        }
    }
}
