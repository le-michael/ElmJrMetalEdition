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
    let graphicsView = EVGraphicsView()
    let menuView = EVMenuView()
    let leftRightDivider = EVDraggableDivider(dragsHorizontally: true)
    let upDownDivider = EVDraggableDivider(dragsHorizontally: false)
    
    var textEditorWidthConstraint: NSLayoutConstraint?
    var textEditorHeightConstraint: NSLayoutConstraint?
        
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
        view.addSubview(textEditorView)
        view.addSubview(leftRightDivider)
        view.addSubview(graphicsView)
        view.addSubview(upDownDivider)
        view.addSubview(menuView)

        setupToolBarLayout()
        setupTextEditorViewLayout()
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
    
    func setupTextEditorViewLayout() {
        textEditorView.translatesAutoresizingMaskIntoConstraints = false
        textEditorView.topAnchor.constraint(equalTo: toolBarView.bottomAnchor, constant: 0).isActive = true
        textEditorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        
        textEditorWidthConstraint = textEditorView.widthAnchor.constraint(equalToConstant: EVEditor.shared.textEditorWidth)
        textEditorWidthConstraint?.isActive = true
        
        textEditorHeightConstraint = textEditorView.heightAnchor.constraint(equalToConstant: EVEditor.shared.textEditorHeight)
        textEditorHeightConstraint?.isActive = true
    }
    
    func setupLeftRightDividerLayout() {
        leftRightDivider.translatesAutoresizingMaskIntoConstraints = false
        leftRightDivider.topAnchor.constraint(equalTo: textEditorView.topAnchor, constant: 0).isActive = true
        leftRightDivider.bottomAnchor.constraint(equalTo: textEditorView.bottomAnchor, constant: 0).isActive = true
        leftRightDivider.leadingAnchor.constraint(equalTo: textEditorView.trailingAnchor, constant: 0).isActive = true
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
        upDownDivider.topAnchor.constraint(equalTo: textEditorView.bottomAnchor, constant: 0).isActive = true
        upDownDivider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        upDownDivider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        upDownDivider.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
    func didUpdateScene(scene: EGScene) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {
        textEditorWidthConstraint?.constant = width
    }
    
    func didChangeTextEditorHeight(height: CGFloat) {
        textEditorHeightConstraint?.constant = height
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









