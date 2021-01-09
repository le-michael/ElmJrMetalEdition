//
//  EditorViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class EVEditorViewController: UIViewController {
    
    let toolBarView = EVToolBarView()
    let textEditorView = EVTextEditorView()
    let projectionalEditorView = EVProjectionalEditorView()
    let graphicsView = EVGraphicsView()
    let menuView = EVMenuView()
    let leftRightDivider = EVDraggableDivider(dragsHorizontally: true)
    let upDownDivider = EVDraggableDivider(dragsHorizontally: false)
    
    let codeEditorView = UIView()
    
    var codeEditorWidthConstraint: NSLayoutConstraint?
    var codeEditorHeightConstraint: NSLayoutConstraint?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        EVEditor.shared.subscribe(delegate: self)
        EVProjectManager.shared.subscribe(delegate: self)
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .darkGray
        
        addDropShadow()
        
        view.addSubview(toolBarView)
        view.addSubview(codeEditorView)
        view.addSubview(leftRightDivider)
        view.addSubview(graphicsView)
        view.addSubview(upDownDivider)
        view.addSubview(menuView)
        
        codeEditorView.addSubview(textEditorView)
        setupTextEditorLayout()

        setupToolBarLayout()
        setupCodeEditorViewLayout()
        setupLeftRightDividerLayout()
        setupGraphicsViewLayout()
        setupUpDownDividerLayout()
        setupMenuViewLayout()
    }
    
    func setupToolBarLayout() {
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        toolBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        toolBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        toolBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        toolBarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupCodeEditorViewLayout() {
        codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        codeEditorView.topAnchor.constraint(equalTo: toolBarView.bottomAnchor, constant: 0).isActive = true
        codeEditorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        
        codeEditorWidthConstraint = codeEditorView.widthAnchor.constraint(equalToConstant: EVEditor.shared.textEditorWidth)
        codeEditorWidthConstraint?.isActive = true
        
        codeEditorHeightConstraint = codeEditorView.heightAnchor.constraint(equalToConstant: EVEditor.shared.textEditorHeight)
        codeEditorHeightConstraint?.isActive = true
    }
    
    func setupLeftRightDividerLayout() {
        leftRightDivider.translatesAutoresizingMaskIntoConstraints = false
        leftRightDivider.topAnchor.constraint(equalTo: codeEditorView.topAnchor, constant: 0).isActive = true
        leftRightDivider.bottomAnchor.constraint(equalTo: codeEditorView.bottomAnchor, constant: 0).isActive = true
        leftRightDivider.leadingAnchor.constraint(equalTo: codeEditorView.trailingAnchor, constant: 0).isActive = true
        leftRightDivider.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupGraphicsViewLayout() {
        graphicsView.translatesAutoresizingMaskIntoConstraints = false
        graphicsView.topAnchor.constraint(equalTo: leftRightDivider.topAnchor, constant: 0).isActive = true
        graphicsView.bottomAnchor.constraint(equalTo: leftRightDivider.bottomAnchor, constant: 0).isActive = true
        graphicsView.leadingAnchor.constraint(equalTo: leftRightDivider.trailingAnchor, constant: 0).isActive = true
        graphicsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    func setupUpDownDividerLayout() {
        upDownDivider.translatesAutoresizingMaskIntoConstraints = false
        upDownDivider.topAnchor.constraint(equalTo: codeEditorView.bottomAnchor, constant: 0).isActive = true
        upDownDivider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        upDownDivider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        upDownDivider.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupTextEditorLayout() {
        textEditorView.translatesAutoresizingMaskIntoConstraints = false
        textEditorView.topAnchor.constraint(equalTo: codeEditorView.topAnchor).isActive = true
        textEditorView.bottomAnchor.constraint(equalTo: codeEditorView.bottomAnchor).isActive = true
        textEditorView.leadingAnchor.constraint(equalTo: codeEditorView.leadingAnchor).isActive = true
        textEditorView.trailingAnchor.constraint(equalTo: codeEditorView.trailingAnchor).isActive = true
    }
    
    func setupProjectionalEditorLayout() {
        projectionalEditorView.translatesAutoresizingMaskIntoConstraints = false
        projectionalEditorView.topAnchor.constraint(equalTo: codeEditorView.topAnchor).isActive = true
        projectionalEditorView.bottomAnchor.constraint(equalTo: codeEditorView.bottomAnchor).isActive = true
        projectionalEditorView.leadingAnchor.constraint(equalTo: codeEditorView.leadingAnchor).isActive = true
        projectionalEditorView.trailingAnchor.constraint(equalTo: codeEditorView.trailingAnchor).isActive = true
    }
    
    func setupMenuViewLayout() {
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.topAnchor.constraint(equalTo: upDownDivider.bottomAnchor, constant: 0).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        menuView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        menuView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    func addDropShadow() {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
    }
}

extension EVEditorViewController: EVEditorDelegate {
    func didToggleMode(isProjectional: Bool) {
        textEditorView.removeFromSuperview()
        projectionalEditorView.removeFromSuperview()
        if isProjectional {
            codeEditorView.addSubview(projectionalEditorView)
            setupProjectionalEditorLayout()
        } else {
            codeEditorView.addSubview(textEditorView)
            setupTextEditorLayout()
        }
    }
    
    func didChangeTextEditorWidth(width: CGFloat) {
        codeEditorWidthConstraint?.constant = width
    }
    
    func didChangeTextEditorHeight(height: CGFloat) {
        codeEditorHeightConstraint?.constant = height
    }
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didLoadProject(project: EVProject) {}
    
    func editor(_ editor: EVEditor, didChangeSourceCode: String){}
    
    func didOpenProjects() {}
}

extension EVEditorViewController: EVProjectManagerDelegate {
    func didUpdateProjects() {}
    
    func didSaveSuccessfully() {
        let alert = UIAlertController(title: "Save successful!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}









