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
    
}
