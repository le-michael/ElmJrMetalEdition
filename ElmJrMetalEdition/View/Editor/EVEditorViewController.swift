//
//  EditorViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class EVEditorViewController: UIViewController {
    
    let editor = EVEditor()

    let toolBarView = EVToolBarView()
    let textEditorView = EVTextEditorView()
    let graphicsView = EVGraphicsView()
    let menuView = EVMenuView()
    let leftRightDivider = EVDraggableDivider(dragsHorizontally: true)
    let upDownDivider = EVDraggableDivider(dragsHorizontally: false)
    
    var textEditorWidthConstraint: NSLayoutConstraint?
    var textEditorHeightConstraint: NSLayoutConstraint?

    var lrDragStartPoint: CGFloat = 0
    var udDragStartPoint: CGFloat = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        editor.delegate = self
        leftRightDivider.editor = editor
        upDownDivider.editor = editor
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .darkGray
        
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
        
        textEditorWidthConstraint = textEditorView.widthAnchor.constraint(equalToConstant: editor.textEditorWidth)
        textEditorWidthConstraint?.isActive = true
        
        textEditorHeightConstraint = textEditorView.heightAnchor.constraint(equalToConstant: editor.textEditorHeight)
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
    
}

extension EVEditorViewController: EVEditorDelegate {
    
    func editor(_ editor: EVEditor, didChangeTextEditorWidth width: CGFloat){
        textEditorWidthConstraint?.constant = width
    }
    
    func editor(_ editor: EVEditor, didChangeTextEditorHeight height: CGFloat){
        textEditorHeightConstraint?.constant = height
    }
    
    func editor(_ editor: EVEditor, didChangeSourceCode: String){
        
    }
    
}









