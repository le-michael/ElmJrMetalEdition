//
//  EVToolBarView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVToolBarView: UIView {
        
    let navigationBar = UINavigationBar()
    var navigationItem: UINavigationItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EVEditor.shared.subscribe(delegate: self)
        addSubview(navigationBar)
        
        navigationBar.barTintColor = EVTheme.Colors.background
        navigationBar.titleTextAttributes = [.foregroundColor: EVTheme.Colors.foreground]
        navigationBar.delegate = self
        
        navigationItem = UINavigationItem()
        navigationItem.title = EVEditor.shared.project.title
        
        let projectsButton = UIBarButtonItem(title: "Projects", style: UIBarButtonItem.Style.plain, target: self, action: #selector(projectsClicked))
        navigationItem.leftBarButtonItem = projectsButton
        projectsButton.tintColor = EVTheme.Colors.highlighted

        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveClicked))
        saveButton.tintColor = EVTheme.Colors.highlighted
        
        let runButton = UIBarButtonItem(title: "Run", style: UIBarButtonItem.Style.plain, target: self, action: #selector(runClicked))
        runButton.tintColor = EVTheme.Colors.highlighted
        
        let toggleModeButton = UIBarButtonItem(title: "Toggle Mode", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleClicked))
        toggleModeButton.tintColor = EVTheme.Colors.highlighted
        
        let separator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        separator.width = 40

        navigationItem.setRightBarButtonItems([saveButton, separator, runButton, separator, toggleModeButton], animated: true)
        
        navigationBar.items = [navigationItem]

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        navigationBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func runClicked(sender: UIBarButtonItem) {
        EVEditor.shared.run()
    }
    
    @objc func projectsClicked(sender: UIBarButtonItem) {
        EVEditor.shared.toggleProjectMenu()
    }
    
    @objc func saveClicked(sender: UIBarButtonItem) {
        EVProjectManager.shared.saveProjects()
    }
    
    @objc func toggleClicked(sender: UIBarButtonItem) {
        EVEditor.shared.toggleMode()
    }
}

extension EVToolBarView: EVEditorDelegate {
    func didToggleMode(isProjectional: Bool) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeTextEditorHeight(height: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {
        navigationItem.title = EVEditor.shared.project.title
    }
    
    
}

extension EVToolBarView: UINavigationBarDelegate {
    
}
