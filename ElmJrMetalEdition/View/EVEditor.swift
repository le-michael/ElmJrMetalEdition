//
//  EVEditor.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-01.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

protocol EVEditorDelegate {
    func didChangeTextEditorWidth(width: CGFloat)
    func didChangeTextEditorHeight(height: CGFloat)
    func didChangeSourceCode(sourceCode: String)
    func didOpenProjects()
    func didLoadProject(project: EVProject)
    func didToggleMode(isProjectional: Bool)
}

class EVEditor {
    
    static let shared = EVEditor()
    
    var delegates: [EVEditorDelegate]
    
    var currentProjectInd: Int
    var textEditorWidth: CGFloat
    var textEditorHeight: CGFloat
    var isInProjectionalMode: Bool
    
    var ast: EINode?
    
    var project: EVProject {
        return EVProjectManager.shared.projects[currentProjectInd]
    }
    
    init(){
        delegates = []
        currentProjectInd = 0
        textEditorWidth = 500
        textEditorHeight = 500
        isInProjectionalMode = false
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
    }
    
    func toggleMode() {
        isInProjectionalMode = !isInProjectionalMode
        delegates.forEach({ $0.didToggleMode(isProjectional: isInProjectionalMode) })
    }
    
    func run() {
        print("raw: --------")
        print(project.sourceCode)
        print("evaluation: ------")
        let evaluator = EIEvaluator()
        do {
            let viewNode = try evaluator.compile(project.sourceCode)
            print(viewNode)
        } catch {
            print("Error evaluating program: \(error)")
        }
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
        do {
            self.ast = try EIParser(text: project.sourceCode).parse()
        } catch {
            print("Unable to convert source code to AST")
            self.ast = nil
        }
    }
    
    func astToSourceCode() {
        guard let newSourceCode = self.ast?.description else {
            print("Unable to convert AST to source code")
            return
        }
        setSourceCode(newSourceCode)
    }
    
}
