//
//  ParserTests.swift
//  UnitTests
//
//  Created by user186747 on 11/25/20.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import XCTest

class EIParserTests: XCTestCase {
    func checkASTExpression(_ toParse: String, _ toOutput: String) throws {
        let ast = try EIParser(text: toParse).parseExpression()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func checkASTDeclaration(_ toParse: String, _ toOutput: String) throws {
        let ast = try EIParser(text: toParse).parseDeclaration()
        XCTAssertEqual("\(ast)", toOutput)
    }
    
    func checkASTEquivalentExpression(_ toParse1: String, _ toParse2: String) throws {
        let ast1 = try EIParser(text: toParse1).parseExpression()
        let ast2 = try EIParser(text: toParse2).parseExpression()
        XCTAssertEqual("\(ast1)", "\(ast2)")
    }
    
    func testIdentifier() throws {
        try checkASTExpression("foo", "foo")
        try checkASTExpression("(bar)", "bar")
        try checkASTExpression("(((moon)))", "moon")
    }
    
    func testMultiply() throws {
        try checkASTExpression("x*y", "(x*y)")
        try checkASTExpression("x*(y*z)", "(x*(y*z))")
    }
    
    func testNegativeNumbers() throws {
        try checkASTExpression("-5", "-5")
        try checkASTExpression("1 + -5", "(1+-5)")
    }
    
    func testMath() throws {
        try checkASTExpression("(1+x)/(y*5.2)", "((1+x)/(y*5.2))")
    }
    
    func testBool() throws {
        try checkASTExpression("True", "True")
        try checkASTExpression("False", "False")
        try checkASTExpression("True || False", "(True||False)")
        try checkASTExpression("False && True", "(False&&True)")
        try checkASTExpression("not False", "(not False)")
        try checkASTExpression("not True || False", "((not True)||False)")
    }
    
    func testMakeFunction() throws {
        try checkASTDeclaration("x = 1", "x = 1")
        try checkASTDeclaration("addone x = x + 1", "addone = (\\x -> (x+1))")
        try checkASTDeclaration("fix f = f (fix f)", "fix = (\\f -> (f (fix f)))")
    }
    
    func testCallFunction() throws {
        try checkASTExpression("f 1", "(f 1)")
        try checkASTExpression("foo 1+1", "((foo 1)+1)")
        try checkASTExpression("bar (foo 6) 3 5", "(((bar (foo 6)) 3) 5)")
        try checkASTExpression("add x y", "((add x) y)")
    }
    
    func testIfElse() throws {
        try checkASTExpression("if 1 then 2 else 3", "if 1 then 2 else 3")
        try checkASTExpression("if 1 then 2 else if 3 then 4 else 5", "if 1 then 2 else if 3 then 4 else 5")
        try checkASTExpression("if 1 then 2 else if 3 then 4 else if 5 then 6 else 7",
                               "if 1 then 2 else if 3 then 4 else if 5 then 6 else 7")
    }
    
    func testTypes() throws {
        try checkASTDeclaration("type T = A Int", "type T = A Int")
        try checkASTDeclaration("type T = A Int Int", "type T = A Int Int")
        try checkASTDeclaration("type A = AB | AC", "type A = AB | AC")
        try checkASTDeclaration("type B = Ba | Bb Int Float", "type B = Ba | Bb Int Float")
        try checkASTDeclaration("type Maybe a = Just a | None", "type Maybe a = Just a | None")
        try checkASTDeclaration("type C a = C a Int | Empty", "type C a = C a Int | Empty")
        try checkASTDeclaration("type E a b = Foo a b", "type E a b = Foo a b")
        try checkASTDeclaration("type F a = Cat (List a) Int", "type F a = Cat (List a) Int")
        try checkASTDeclaration("type T = TA (Int, Int) | TB (List Int, Float) | TC (Int, Int, Int)",
                                "type T = TA (Int, Int) | TB (List Int, Float) | TC (Int, Int, Int)")
        try checkASTDeclaration("type T = TA ((Int,(Int,Int)),Int)", "type T = TA ((Int, (Int, Int)), Int)")
        try checkASTDeclaration("type T = A Int | B T T", "type T = A Int | B T T")
        try checkASTDeclaration("type T = A (Int -> Float)", "type T = A (Int -> Float)")
        try checkASTDeclaration("type T = A (Int -> Int -> Int) | B (List Int -> Float) Int",
                                "type T = A (Int -> Int -> Int) | B (List Int -> Float) Int")
    }
    
    func testTuple() throws {
        try checkASTExpression("(1,2)", "(1, 2)")
        try checkASTExpression("(1,(3,4))", "(1, (3, 4))")
        try checkASTExpression("((True,False),(5,6,7))", "((True, False), (5, 6, 7))")
    }
    
    func testList() throws {
        try checkASTExpression("[]", "[]")
        try checkASTExpression("[1]", "[1]")
        try checkASTExpression("[True,False]", "[True, False]")
        try checkASTExpression("[1,2,3,4,5,6]", "[1, 2, 3, 4, 5, 6]")
    }
    
    func testListCat() throws {
        try checkASTExpression("[] ++ []", "([]++[])")
        try checkASTExpression("[] ++ [1,2]", "([]++[1, 2])")
        try checkASTExpression("[True, False] ++ []", "([True, False]++[])")
        try checkASTExpression("[1,2,3,4] ++ [5,6,7,8]", "([1, 2, 3, 4]++[5, 6, 7, 8])")
    }
    
    func testListPushLeft() throws {
        try checkASTExpression("1::[]", "(1::[])")
        try checkASTExpression("1::2::[]", "(1::(2::[]))")
    }
    
    func testStringCat() throws {
        // TODO: I just realized I never implemented strings.
        // These tests should be enabled when we have string support
        // try checkASTExpression("\"cat\" ++ \"dog\"", "(\"cat\"++\"dog\")")
        // try checkASTExpression("\"a\" ++ \"b\" ++ \"c\"", "((\"a\"++\"b\") ++ \"c\")")
    }
    
    func testFuncAnnotation() throws {
        try checkASTDeclaration("f : Int -> Int \n f x = x + 1", "f = (\\x -> (x+1))")
        try checkASTDeclaration("f : Int -> List Int \n f x = [x]", "f = (\\x -> [x])")
        try checkASTDeclaration("f : number -> List number \n f x = [x]", "f = (\\x -> [x])")
    }
    
    func testNOVALUE() throws {
        try checkASTExpression("NOVALUE", "NOVALUE")
        try checkASTExpression("(1 + NOVALUE)", "(1+NOVALUE)")
    }
    
    func testFancyFunctionApplication() throws {
        try checkASTEquivalentExpression("f 1 2", "2 |> f 1")
        try checkASTEquivalentExpression("f 1 2 3", "(3 |> (2 |> f 1))")
        try checkASTEquivalentExpression("move (0, 2.25, 0) (color (rgb 1 1 1) sphere)",
                                         "sphere |> color (rgb 1 1 1) |> move (0, 2.25, 0)")
        try checkASTEquivalentExpression("move (0, 2.25, 0) (color (rgb 1 1 1) sphere)",
                                         "sphere \n |> color (rgb 1 1 1) \n |> move (0, 2.25, 0)")
        try checkASTEquivalentExpression("f 1 2", "f 1 <| 2")
        try checkASTEquivalentExpression("f 1 2 3", "f 1 <| 2 <| 3")
        try checkASTEquivalentExpression("move (0, 2.25, 0) (color (rgb 1 1 1) sphere)",
                                         "move (0, 2.25, 0) <| (color (rgb 1 1 1) <| sphere)")
    }
}
