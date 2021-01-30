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
    
    func testTranspile() throws {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "bigtest1", ofType: "elm")!
        let data : Data = Data(referencing: try NSData(contentsOfFile: path))
        let text = String(data: data, encoding: .utf8)
        let evaluator = EIEvaluator()
        try evaluator.compile(text!)
        transpile(node: evaluator.globals["myScene"]!)
        //input:
        //(Scene (Camera (Translate (0, 0, 0))) [(ApTransform (Translate (50, 50, 1)) (Inked (Just (RGBA 204 0 0 1)) (Polygon 3 50)))])
    }
}

