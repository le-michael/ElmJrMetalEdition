//
//  EITypeInferencerTests.swift
//  UnitTests
//
//  Created by Lucas Dutton on 2020-12-10.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import XCTest
@testable import ElmJrMetalEdition

class EITypeInferencerTests: XCTestCase {
    func checkDeclrTy(_ toEvaluate : String, _ toOutput : String, _ typeVars : [String] = [])
        throws {
        let ast : EIAST.Declaration = try EIParser(text: toEvaluate).parse() as! EIAST.Declaration
        let expectedType : MonoType = try EIParser(text: toOutput).type(typeVars: typeVars, bounded: true, annotation: true)
        let typeChecker = EITypeInferencer(parsed : [ast])
        let tyEnv = try typeChecker.inferTop()
        XCTAssertTrue(try EITypeInferencer.TySig(tyEnv).tcTySigTop(expectedType, ast.name))
    }
    
    func checkExprTy(_ toEvaluate : String, _ toOutput : String)
        throws {
        let ast = try EIParser(text: toEvaluate).parseExpression()
        let tyEnv = try EITypeInferencer(parsed : [ast]).inferTop()
        XCTAssertEqual("\(try tyEnv.lookup("\(ast.description)").description)", toOutput)
    }
    
    func checkTypeCheckErr(_ toEvaluate : String)
        throws {
        let ast = try EIParser(text : toEvaluate).parseExpression()
        XCTAssertThrowsError(try EITypeInferencer(parsed : [ast]).inferTop())
    }
    
    func testLiteralTypes() throws {
        try checkExprTy("3", "number")
        try checkExprTy("3.5", "Float")
    }
    
    func testOperators() throws {
        try checkExprTy("3+4", "number")
        try checkExprTy("3.5+4", "Float")
        try checkTypeCheckErr("True + 1")
        // variables unimplemented
        // try checkSimpleExpressionTy("3+x", "number")
        // try checkSimpleExpressionTy("x+y", "number")
        // try checkSimpleExpressionTy(("2.0+x"), "Float")
    }
    
    func testIfElse() throws {
        try checkExprTy("if True then 1 else 2", "number")
        try checkExprTy("if False then 0 else if False then 1 else 2.2", "Float")
        try checkTypeCheckErr("if 1+2 then True else False")
        try checkTypeCheckErr("if False then 1 else True")
    }
    
    func testFunctions() throws {
        try checkDeclrTy("addone x = x + 1", "number -> number")
        try checkDeclrTy("p x = x <= 2.2", "Float -> Bool")
        try checkDeclrTy("id alongstring = alongstring", "a -> a", ["a"])
        try checkDeclrTy("fix f = f (fix f)", "(a -> a) -> a", ["a"])
        try checkDeclrTy("ap f x = f x", "(a -> b) -> a -> b", ["a", "b"])
        try checkDeclrTy("flip f a b = f b a", "(b -> a -> c) -> a -> b -> c", ["a", "b", "c"])
        try checkDeclrTy("fac x = if x == 0 then 1 else x * fac (x - 1)", "number -> number")
        try checkDeclrTy("fib n = if n == 0 then 0 else if n == 1 then 1 else fib (n - 1) + fib (n - 2)", "number1 -> number")
        try checkDeclrTy("compose f g x = f (g x)", "(b -> c) -> (a -> b) -> a -> c", ["a", "b", "c"])
    }
    
    func testTemp() throws {
        // try checkDeclrTy("fix f = f (fix f)", "(a -> a) -> a")
        try checkDeclrTy("fac x = if x == 0 then 1 else x * fac (x - 1)", "number -> number")
    }
}
