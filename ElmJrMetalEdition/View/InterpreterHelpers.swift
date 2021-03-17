//
//  InterpreterHelpers.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-03-04.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
import MetalKit

func compileWithLibraries(sourceCode: String) -> EGScene{
    do {
        let toLoad = ["Maybe","Builtin","Base","API3D"]
        var code = try toLoad.map{ try getElmFile($0) }.joined(separator: "\n")
        code.append("\n"+sourceCode)
        let evaluator = try EIEvaluator()
        try evaluator.compile(code)

        guard let sceneNode = evaluator.globals["scene"] else { return EGScene() }
        let transpiler = EGTranspiler()
        let scene = transpiler.transpile(node: sceneNode)
        return scene

    }
    catch {
        return EGScene()
    }
}

func compileNode(sourceCode: String) -> EINode {
    do {
        let parser = try EIParser(text: sourceCode)
        let node = try parser.parseExpression()
        return node
    }
    catch {
        return EIAST.NoValue()
    }
}

func compileDeclaration(sourceCode: String) -> EINode {
    do {
        let parser = try EIParser(text: sourceCode)
        let node = try parser.parseDeclaration()
        return node
    }
    catch {
        return EIAST.NoValue()
    }
}

func getElmFile(_ filename: String) throws -> String {
    let bundle = Bundle.main
    let path = bundle.path(forResource: filename, ofType: "elm")!
    let data : Data = Data(referencing: try NSData(contentsOfFile: path))
    return String(data: data, encoding: .utf8)!
}
