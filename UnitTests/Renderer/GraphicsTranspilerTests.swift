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
    
//    func testTranspile() throws {
//        let bundle = Bundle(for: type(of: self))
//        let path = bundle.path(forResource: "bigtest1", ofType: "elm")!
//        let data : Data = Data(referencing: try NSData(contentsOfFile: path))
//        let text = String(data: data, encoding: .utf8)
//        let evaluator = EIEvaluator()
//        try evaluator.compile(text!)
//        transpile(node: evaluator.globals["myScene"]!)
//        //input:
//        //(Scene (Camera (Translate (0, 0, 0))) [(ApTransform (Translate (50, 50, 1)) (Inked (Just (RGBA 204 0 0 1)) (Polygon 3 50)))])
//    }
    
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
        let evaluator = EIEvaluator()
        try evaluator.compile(code)
        print("\(evaluator.globals["scene"]!)")
        print(" ")
        print("______________________")
        transpile(node: (evaluator.globals["scene"]!))
        print("____________")
    }

    func testThreeDee() throws {
        //try run3DTest("ThreeDee")
        try run3DTest("SnowMan")
    }
    
    
    //(SceneWithTime (ArcballCamera 5 (0, -1, 0) Nothing Nothing) [(DirectionalLight (RGB 0.6 0.6 0.6) (1, 2, 2) (RGB 0.1 0.1 0.1)), (AmbientLight (RGB 1 1 1) 0.5)]
    //(ApTransform (Translate (0, 2.15, 0.5)) (ApTransform (Scale (0.1, 0.1, 0.1)) (ApTransform (Rotate3D (90, 0, 0)) (Inked (Just (RGBA 0.20392157 0.68235296 0.39607844 1)) Capsule))))
    //(ApTransform (Translate (0, 2.7, 0)) (ApTransform (Scale (0.35, 0.02, 0.35)) (Inked (Just (RGBA 0.1 0.1 0.1 1)) Cylinder)))
}

