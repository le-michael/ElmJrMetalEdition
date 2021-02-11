//
//  EVProjectionalEditorVIew.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-09.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVProjectionalEditorView: UIView {
    
    var astNodeViews = UIStackView()
    var referenceTransform: CGAffineTransform?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EVEditor.shared.subscribe(delegate: self)
        backgroundColor = EVTheme.Colors.background
        layer.masksToBounds = true
        setupGestures()
        updateASTView()
        addSubview(astNodeViews)
    }
    
    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView(sender:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pannedView(sender:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc func pinchedView(sender: UIPinchGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began){
            referenceTransform = astNodeViews.transform
        } else {
            guard let transform = referenceTransform?.scaledBy(x: sender.scale, y: sender.scale) else { return }
            astNodeViews.transform = transform
        }
    }
    
    @objc func pannedView(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began){
            referenceTransform = astNodeViews.transform
        } else {
            guard let refTransform = referenceTransform else { return }
            let transform = refTransform.translatedBy(
                x: sender.translation(in: self).x / refTransform.a,
                y: sender.translation(in: self).y / refTransform.a
            )
            astNodeViews.transform = transform
        }
    }
    
    func updateASTView() {
        astNodeViews.axis = .vertical
        astNodeViews.alignment = .leading
        astNodeViews.translatesAutoresizingMaskIntoConstraints = false
        astNodeViews.spacing = 10
        for view in astNodeViews.arrangedSubviews {
            astNodeViews.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for projectionalNode in EVEditor.shared.astNodes {
            astNodeViews.addArrangedSubview(projectionalNode.getUIView(isStore: false))
        }
    }

    func getErrorLabelView(message: String) -> UIView {
        let label = UILabel()
        label.text = "Error: \(message)"
        label.textColor = .red
        return label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EVProjectionalEditorView: EVEditorDelegate {
    func didUpdateScene(scene: EGScene) {}
    
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeTextEditorHeight(height: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {
        updateASTView()
    }
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {
        updateASTView()
    }
    
    func didToggleMode(isProjectional: Bool) {
        updateASTView()
    }
}
