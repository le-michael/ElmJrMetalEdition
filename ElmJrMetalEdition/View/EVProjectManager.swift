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

class EVProjectManager {
    
    static let shared = EVProjectManager()
    
    var projects: [EVProject] = []
    var delegates: [EVProjectManagerDelegate] = []
    
    init() {
        fetchProjectsFromFileSystem()
        if projects.count == 0 {
            projects.append(EVProject(title: "New Project", sourceCode: ""))
        }
        if !projectExists("SnowManDemo") {
            let code = try! getElmFile("SnowMan")
            projects.append(EVProject(title: "SnowManDemo", sourceCode: code))
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
        projects.append(EVProject(title: projectName, sourceCode: ""))
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
