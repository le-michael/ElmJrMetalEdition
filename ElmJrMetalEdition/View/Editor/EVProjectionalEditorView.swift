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
        
        let addDeclarationButton = UIButton()
        addDeclarationButton.setTitle("+ Add Declaration", for: .normal)
        addDeclarationButton.addTarget(self, action: #selector(_handleAddDeclaration), for: .touchUpInside)
        astNodeViews.addArrangedSubview(addDeclarationButton)
    }
    
    @objc func _handleAddDeclaration() {
        
        let timeFunction = compileDeclaration(sourceCode: """
            newFunction time = (cube
                |> color (rgb 0.0 0.0 0.0)
                |> move (0.0, 0.0, 0.0))
        """)
        let timeFunctionOption = EVNodeMenuOption(node: timeFunction as! EVProjectionalNode, description: "Function that returns a shape given time") {
            let alert = UIAlertController(title: "Choose a name for the function", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            alert.addAction(UIAlertAction(title: "Create function", style: .default, handler: { [weak alert] (_) in
                guard let varName = alert?.textFields![0].text else { return }
                EVEditor.shared.functionNames.append(varName)

                let cubeImplementation = compileDeclaration(sourceCode: """
                    \(varName) time = (cube
                        |> color (rgb 0.0 0.0 0.0)
                        |> move (time, 0.0, 0.0))
                """)
                EVEditor.shared.astNodes.insert(cubeImplementation as! EVProjectionalNode, at: 0)

                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }))
            self.parentViewController?.present(alert, animated: true, completion: nil)
        }
        
        let floatFunction = compileDeclaration(sourceCode: """
            floatFunction x = (cube
                |> color (rgb 0.0 0.0 0.0)
                |> move (x, 0.0, 0.0))
        """)
        let floatFunctionOption = EVNodeMenuOption(node: floatFunction as! EVProjectionalNode, description: "Function that returns a shape given a float") {
            let alert = UIAlertController(title: "Choose a name for the function", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "floatFunction"
            }
            alert.addTextField { (textField) in
                textField.text = "num"
            }
            alert.addAction(UIAlertAction(title: "Create declaration", style: .default, handler: { [weak alert] (_) in
                guard let varName = alert?.textFields![0].text else { return }
                guard let argName = alert?.textFields![1].text else { return }
                EVEditor.shared.functionNames.append(varName)
                EVEditor.shared.variableNames.append(argName)

                let cubeImplementation = compileDeclaration(sourceCode: """
                    \(varName) \(argName) = (cube
                        |> color (rgb 0.0 0.0 0.0)
                        |> move (0.0, 0.0, 0.0))
                """)
                EVEditor.shared.astNodes.insert(cubeImplementation as! EVProjectionalNode, at: 0)

                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }))
            self.parentViewController?.present(alert, animated: true, completion: nil)
        }
        
        
        
        EVEditor.shared.openNodeMenu(title: "Add Declaration", options: [
            timeFunctionOption,
            floatFunctionOption
        ])
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
    func didUpdateModelPreview(modelFileName: String) {}
    
    func didOpenNodeMenu(title: String, options: [EVNodeMenuOption]) {}

    func didCloseNodeMenu() {}
    
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

    func didToggleMode() {
        updateASTView()
    }
}
