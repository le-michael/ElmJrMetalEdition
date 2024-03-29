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
    let leftRightDivider = EVDraggableDivider()
    let codeEditorView = UIView()
    
    var nodeMenuView: EVNodeMenu?
    var modelPreview: EVModelPreview?

    var textEditorWidthConstraint: NSLayoutConstraint?
        
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
        view.addSubview(menuView)
        
        codeEditorView.addSubview(textEditorView)
        setupTextEditorLayout()

        setupToolBarLayout()
        setupCodeEditorViewLayout()
        setupLeftRightDividerLayout()
        setupGraphicsViewLayout()
        setupModelPreview()
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
        codeEditorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        codeEditorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        textEditorWidthConstraint = codeEditorView.widthAnchor.constraint(equalToConstant: EVEditor.shared.textEditorWidth)
        textEditorWidthConstraint?.isActive = true
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
    
    func setupModelPreview() {
        modelPreview = EVModelPreview()
        view.addSubview(modelPreview!)
        modelPreview?.translatesAutoresizingMaskIntoConstraints = false
        modelPreview?.topAnchor.constraint(equalTo: toolBarView.bottomAnchor, constant: 16).isActive = true
        modelPreview?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        modelPreview?.widthAnchor.constraint(equalToConstant: 300).isActive = true
        modelPreview?.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
    func addDropShadow() {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
    }
}

extension EVEditorViewController: EVEditorDelegate {
    func didUpdateModelPreview(modelFileName: String) {}
    
    func didOpenNodeMenu(title: String, options: [EVNodeMenuOption]) {
        nodeMenuView?.removeFromSuperview()
        nodeMenuView = EVNodeMenu(title: title, options: options)
        view.addSubview(nodeMenuView!)
        nodeMenuView?.translatesAutoresizingMaskIntoConstraints = false
        nodeMenuView?.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        nodeMenuView?.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        nodeMenuView?.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        nodeMenuView?.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true

    }
    
    func didCloseNodeMenu() {
        nodeMenuView?.removeFromSuperview()
    }
    
    func didUpdateScene(scene: EGScene) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {
        textEditorWidthConstraint?.constant = width
    }
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didLoadProject(project: EVProject) {}
    
    func editor(_ editor: EVEditor, didChangeSourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didToggleMode() {
        textEditorView.removeFromSuperview()
        projectionalEditorView.removeFromSuperview()
        if EVEditor.shared.mode == .projectional {
            codeEditorView.addSubview(projectionalEditorView)
            setupProjectionalEditorLayout()
        } else {
            codeEditorView.addSubview(textEditorView)
            setupTextEditorLayout()
        }
    }
}

extension EVEditorViewController: EVProjectManagerDelegate {
    func didUpdateProjects() {}
    
    func didSaveSuccessfully() {
        let alert = UIAlertController(title: "Save successful!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}









