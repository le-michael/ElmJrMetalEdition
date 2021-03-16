//
//  EVProjectManager.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-04.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

protocol EVProjectManagerDelegate {
    func didSaveSuccessfully()
    func didUpdateProjects()
}

let starterCode = """
myShapes : Float -> List Shape
myShapes time =
    [ sphere
        |> color (rgb 1.0 1.0 1.0)
    ]

lights =
    [ DirectionalLight Nothing (RGB (0.6, 0.6, 0.6)) (1.0, 2.0, 2.0) (RGB (0.1, 0.1, 0.1))
    , AmbientLight Nothing (RGB (1.0, 1.0, 1.0)) 0.5
    ]

scene = viewWithTimeAndCamera (ArcballCamera 5 (0, -1, 0) Nothing Nothing) (RGB (0.529, 0.808, 0.922)) (\\f -> lights) myShapes
"""

class EVProjectManager {
    
    static let shared = EVProjectManager()
    
    var projects: [EVProject] = []
    var delegates: [EVProjectManagerDelegate] = []
    
    init() {
        fetchProjectsFromFileSystem()
        if projects.count == 0 {
            projects.append(EVProject(title: "New Project", sourceCode: starterCode))
        }
        if !projectExists("Snow Man Demo") {
            let code = try! getElmFile("SnowMan")
            projects.append(EVProject(title: "Snow Man Demo", sourceCode: code))
        }
    }
    
    func subscribe(delegate: EVProjectManagerDelegate) {
        delegates.append(delegate)
    }
    
    func fetchProjectsFromFileSystem() {
        var fetchedProjects: [EVProject] = []
        
        let defaults = UserDefaults.standard
        let titles:[String] = defaults.array(forKey: "titles") as? [String] ?? [String]()
        let sourceCodes:[String] = defaults.array(forKey: "sourceCodes") as? [String] ?? [String]()
        
        for (title, sourceCode) in zip(titles, sourceCodes){
            fetchedProjects.append(EVProject(title: title, sourceCode: sourceCode))

        }
        
        projects = fetchedProjects
    }
    
    func saveProjects() {
        let defaults = UserDefaults.standard
        var titles:[String] = []
        var sourceCodes:[String] = []
        for project in projects {
            titles.append(project.title)
            sourceCodes.append(project.sourceCode)
        }
        defaults.set(titles, forKey: "titles")
        defaults.set(sourceCodes, forKey: "sourceCodes")
        delegates.forEach({ $0.didSaveSuccessfully() })
    }
    
    func createProject(projectName: String) {
        projects.append(EVProject(title: projectName, sourceCode: starterCode))
        saveProjects()
        delegates.forEach({ $0.didUpdateProjects() })
    }
    
    private func projectExists(_ title: String) -> Bool {
        for project in projects {
            if project.title == title {
                return true
            }
        }
        return false
    }
    
}
