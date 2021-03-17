//
//  GraphicsTranspilerTests.swift
//  UnitTests
//
//  Created by Saad Khan on 2021-01-29.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class GraphicsTranspilerTests: XCTestCase {

    func getElmFile(_ filename: String) throws -> String {
        //let bundle = Bundle(for: type(of: self))
        let bundle = Bundle.main
        let path = bundle.path(forResource: filename, ofType: "elm")!
        let data : Data = Data(referencing: try NSData(contentsOfFile: path))
        return String(data: data, encoding: .utf8)!
    }
    
    func run3DTest(_ filename: String) throws {
        //let toLoad = ["Maybe","Builtin","Base","API3D"]
        let toLoad = ["Maybe","Builtin","Base","API3D",filename]
        let code = try toLoad.map{ try getElmFile($0) }.joined(separator: "\n")
        let evaluator = try EIEvaluator()
        try evaluator.compile(code)
        print("\(evaluator.globals["scene"]!)")
        print(" ")
        print("______________________")
        let transpiler = EGTranspiler()
        transpiler.transpile(node: (evaluator.globals["scene"]!))
        print("____________")
    }

    func testThreeDee() throws {
        //try run3DTest("ThreeDee")
        try run3DTest("SnowMan")
    }
}

