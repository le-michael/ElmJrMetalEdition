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
    func didUpdateScene(scene: EGScene)
}

class EVEditor {
    
    static let shared = EVEditor()
    
    var delegates: [EVEditorDelegate]
    
    var currentProjectInd: Int
    var textEditorWidth: CGFloat
    var textEditorHeight: CGFloat
    var scene: EGScene
    
    var project: EVProject {
        return EVProjectManager.shared.projects[currentProjectInd]
    }
    
    init(){
        delegates = []
        currentProjectInd = 0
        textEditorWidth = 500
        textEditorHeight = 500
        scene = EGScene()
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
        delegates.forEach({ $0.didChangeSourceCode(sourceCode: sourceCode) })
    }
    
    func toggleProjectMenu() {
        delegates.forEach({ $0.didOpenProjects() })
    }
    
    func loadProject(projectTitle: String) {
        for (ind, project) in EVProjectManager.shared.projects.enumerated() {
            if project.title == projectTitle {
                currentProjectInd = ind
                delegates.forEach({ $0.didLoadProject(project: project) })
            }
        }
        run()
    }
    
    func run() {
        scene = compileWithLibraries(sourceCode: project.sourceCode)
        delegates.forEach({ $0.didUpdateScene(scene: scene) })
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
        let transpiler = EGTranspiler()
        let scene = transpiler.transpile(node: sceneNode) as! EGScene
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
