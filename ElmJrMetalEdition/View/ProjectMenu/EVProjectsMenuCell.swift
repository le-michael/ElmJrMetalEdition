//
//  EVProjectsMenuCell.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-04.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVProjectsMenuCell: UICollectionViewCell {
        
    var project: EVProject?
    
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EVEditor.shared.subscribe(delegate: self)
        addSubview(button)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.titleLabel?.textColor = EVTheme.Colors.foreground
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func updateSelectionColor(){
        guard let title = self.project?.title else { return }
        if EVEditor.shared.project.title == title {
            button.backgroundColor = EVTheme.Colors.activeSelectionBackground
        } else {
            button.backgroundColor = .clear
        }
    }
    
    func setProject(project: EVProject) {
        self.project = project
        button.setTitle(project.title, for: .normal)
        updateSelectionColor()
    }
    
    @objc func buttonPressed(){
        guard let projectTitle = project?.title else { return }
        EVEditor.shared.loadProject(projectTitle: projectTitle)
        EVEditor.shared.toggleProjectMenu()
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EVProjectsMenuCell: EVEditorDelegate {
    func didToggleMode(isProjectional: Bool) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeTextEditorHeight(height: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {
        updateSelectionColor()
    }
}
