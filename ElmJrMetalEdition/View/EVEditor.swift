//
//  EVEditor.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-01.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

protocol EVEditorDelegate {
    func didChangeTextEditorWidth(width: CGFloat)
    func didChangeTextEditorHeight(height: CGFloat)
    func didChangeSourceCode(sourceCode: String)
    func didOpenProjects()
    func didLoadProject(project: EVProject)
    func didToggleMode(isProjectional: Bool)
    func didUpdateScene(scene: EGScene)
}

class EVEditor {
    
    static let shared = EVEditor()
    
    var delegates: [EVEditorDelegate]
    
    var currentProjectInd: Int
    var textEditorWidth: CGFloat
    var textEditorHeight: CGFloat
    var isInProjectionalMode: Bool
    
    var astNodes: [EVProjectionalNode]
    var scene: EGScene
    
    var project: EVProject {
        return EVProjectManager.shared.projects[currentProjectInd]
    }
    
    init(){
        delegates = []
        currentProjectInd = 0
        textEditorWidth = 500
        textEditorHeight = 500
        isInProjectionalMode = false
        scene = EGScene()
        astNodes = []
        run()
    }
    
    func subscribe(delegate: EVEditorDelegate) {
        delegates.append(delegate)
    }
    
    func setTextEditorWidth(_ width: CGFloat) {
        textEditorWidth = width
        delegates.forEach({ $0.didChangeTextEditorWidth(width: width) })
    }
    
    func setTextEditorHeight(_ height: CGFloat) {
        textEditorHeight = height
        delegates.forEach({ $0.didChangeTextEditorHeight(height: height) })
    }
    
    func setSourceCode(_ sourceCode: String) {
        project.sourceCode = sourceCode
        sourceCodeToAst()
        delegates.forEach({ $0.didChangeSourceCode(sourceCode: sourceCode) })
    }
    
    func toggleProjectMenu() {
        delegates.forEach({ $0.didOpenProjects() })
    }
    
    func loadProject(projectTitle: String) {
        for (ind, project) in EVProjectManager.shared.projects.enumerated() {
            if project.title == projectTitle {
                currentProjectInd = ind
                sourceCodeToAst()
                delegates.forEach({ $0.didLoadProject(project: project) })
            }
        }
        run()
    }
    
    func toggleMode() {
        if isInProjectionalMode {
            astToSourceCode()
        } else {
            sourceCodeToAst()
        }
        isInProjectionalMode = !isInProjectionalMode
        delegates.forEach({ $0.didToggleMode(isProjectional: isInProjectionalMode) })
    }
    
    func run() {
        
        scene = compileWithLibraries(sourceCode: project.sourceCode)
        delegates.forEach({ $0.didUpdateScene(scene: scene) })
    }
    
    func getAST() -> EINode? {
        do {
            let ast = try EIParser(text: project.sourceCode).parse()
            return ast
        } catch {
            return nil
        }
    }
    
    func sourceCodeToAst() {
        let nodes = parseWithLibraries(sourceCode: project.sourceCode)
        self.astNodes = nodes
    }
    
    func astToSourceCode() {
        var newSourceCode = ""
        for ast in astNodes {
            let eiNode = ast as! EINode
            newSourceCode += eiNode.description
            newSourceCode += "\n"
        }
        setSourceCode(newSourceCode)
    }
    
}

func parseWithLibraries(sourceCode: String) -> [EVProjectionalNode] {
    do {
        var nodes: [EVProjectionalNode] = []
        
        let toLoad = ["Maybe","Builtin","Base","API3D"]
        var code = try toLoad.map{ try getElmFile($0) }.joined(separator: "\n")
        code.append("\n"+sourceCode)
        let evaluator = EIEvaluator()
        try evaluator.compile(code)
        
        let parser = evaluator.parser
        try parser.appendText(text: sourceCode)
        while !parser.isDone() {
            let ast = try parser.parseDeclaration() as! EVProjectionalNode
            nodes.append(ast)
        }
        return nodes
    } catch {
        print("Error parsing with libraries: \(error)")
        return []
    }
}

func compileWithLibraries(sourceCode: String) -> EGScene{
    do {
        let toLoad = ["Maybe","Builtin","Base","API3D"]
        var code = try toLoad.map{ try getElmFile($0) }.joined(separator: "\n")
        code.append("\n"+sourceCode)
        let evaluator = EIEvaluator()
        try evaluator.compile(code)

        guard let sceneNode = evaluator.globals["scene"] else { return EGScene() }
        let scene = transpile(node: sceneNode) as! EGScene
        scene.viewClearColor = MTLClearColorMake(0.529, 0.808, 0.922, 1.0)
        return scene
    }
    catch {
        return EGScene()
    }
}

func getElmFile(_ filename: String) throws -> String {
    let bundle = Bundle.main
    let path = bundle.path(forResource: filename, ofType: "elm")!
    let data : Data = Data(referencing: try NSData(contentsOfFile: path))
    return String(data: data, encoding: .utf8)!
}
