//
//  ContainerViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-03.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit


class EVContainerViewController: UIViewController {
    
    
    var editorViewController: EVEditorViewController!
    var menuViewController: EVProjectMenuViewController!
    var isExpanded = false
    
    let expandedOffset: CGFloat = 90

    override func viewDidLoad() {
        super.viewDidLoad()
        EVEditor.shared.subscribe(delegate: self)
        
        editorViewController = EVEditorViewController()
        menuViewController = EVProjectMenuViewController()
        
        view.addSubview(editorViewController.view)
        view.insertSubview(menuViewController.view, at: 0)
        addChild(editorViewController)
        addChild(menuViewController)
    }
    
    func animateEditorToXPosition(_ x: CGFloat) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: {
                self.editorViewController.view.frame.origin.x = x
            })
    }
    
}

extension EVContainerViewController: EVEditorDelegate {
    func didToggleMode(isProjectional: Bool) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeTextEditorHeight(height: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didLoadProject(project: EVProject) {}
    
    func didOpenProjects() {
        if !isExpanded {
            isExpanded = true
            animateEditorToXPosition(300)
        } else {
            isExpanded = false
            animateEditorToXPosition(0)
        }
    }
}
