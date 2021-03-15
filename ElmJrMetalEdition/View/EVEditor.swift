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
    func didChangeSourceCode(sourceCode: String)
    func didOpenProjects()
    func didLoadProject(project: EVProject)
    func didUpdateScene(scene: EGScene)
    func didToggleMode()
    func didOpenNodeMenu(title: String, options: [EVNodeMenuOption])
    func didCloseNodeMenu()
}

class EVEditor {
    
    enum Mode {
        case text
        case projectional
    }
    
    static let shared = EVEditor()
    
    var delegates: [EVEditorDelegate]
    
    var currentProjectInd: Int
    var textEditorWidth: CGFloat
    var textEditorHeight: CGFloat
    var scene: EGScene
    var mode: Mode
    var astNodes: [EVProjectionalNode]
    
    var functionNames: [String]
    var variableNames: [String]

    var project: EVProject {
        return EVProjectManager.shared.projects[currentProjectInd]
    }
    
    init(){
        delegates = []
        currentProjectInd = 0
        textEditorWidth = 500
        textEditorHeight = 500
        scene = EGScene()
        mode = .text
        astNodes = []
        functionNames = []
        variableNames = []
        run()
    }
    
    func subscribe(delegate: EVEditorDelegate) {
        delegates.append(delegate)
    }
    
    func setTextEditorWidth(_ width: CGFloat) {
        textEditorWidth = width
        delegates.forEach({ $0.didChangeTextEditorWidth(width: width) })
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
        if self.mode == .projectional {
            astToSourceCode()
            self.mode = .text
        } else {
            sourceCodeToAst()
            self.mode = .projectional
        }
        delegates.forEach({ $0.didToggleMode() })
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
        run()
    }

    
    func run() {
        scene = compileWithLibraries(sourceCode: project.sourceCode)
        delegates.forEach({ $0.didUpdateScene(scene: scene) })
    }
    
    func openNodeMenu(title: String, options: [EVNodeMenuOption]) {
        delegates.forEach({
            $0.didOpenNodeMenu(title: title, options: options)
        })
    }
    
    func closeNodeMenu() {
        delegates.forEach({ $0.didCloseNodeMenu() })
    }
    
}

func parseWithLibraries(sourceCode: String) -> [EVProjectionalNode] {
    do {
        var nodes: [EVProjectionalNode] = []

        let toLoad = ["Maybe","Builtin","Base","API3D"]
        var code = try toLoad.map{ try getElmFile($0) }.joined(separator: "\n")
        code.append("\n"+sourceCode)
        let evaluator = try EIEvaluator()
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


