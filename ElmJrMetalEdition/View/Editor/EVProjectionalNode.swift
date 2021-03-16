//
//  EVProjectionalNode.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-08.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVProjectionalNodeView: UIView {
    static var padding: CGFloat = 5
    
    var innerView: UIView!
    var isStore: Bool!
    var tapHandler: () -> Void = {}
    var dropHandler: (EINode) -> Void = { _ in }
    var node: EINode!
    
    init(node: EINode, view: UIView, padding: UIEdgeInsets, isStore: Bool = false) {
        super.init(frame: .zero)
        EVEditor.shared.subscribe(delegate: self)
        innerView = view
        self.isStore = isStore
        self.node = node
        addSubview(innerView)

        backgroundColor = EVTheme.Colors.background
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
        innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom).isActive = true
        innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left).isActive = true
        innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right).isActive = true
        
        if isStore {
            setupDrag()
        } else {
            setupDrop()
        }
    }
    
    func addTapCallback(callback: @escaping () -> Void) {
        tapHandler = callback
        setupTapGesture()
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true
    }
    
    func setupDrag() {
        let dragInteraction = UIDragInteraction(delegate: self)
        addInteraction(dragInteraction)
    }
    
    func setupDrop() {
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
    }
    
    func highlight() {
        layer.borderWidth = 2
        layer.borderColor = EVTheme.Colors.ProjectionalEditor.action?.cgColor
    }
    
    func unhighlight() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("Tapped")
        tapHandler()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EVProjectionalNodeView: EVEditorDelegate {
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {}
    
    func didUpdateScene(scene: EGScene) {}
    
    func didToggleMode() {}
    
    func didOpenNodeMenu(title: String, options: [EVNodeMenuOption]) {
        unhighlight()
    }
    
    func didCloseNodeMenu() {
        unhighlight()
    }
}

extension EVProjectionalNodeView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let stringItemProvider = NSItemProvider(object: node.description as NSString)
        return [UIDragItem(itemProvider: stringItemProvider)]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {}
}

extension EVProjectionalNodeView: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: NSString.self) { nodes in
            let nodeString = nodes[0] as! NSString
            let node = try! EIParser(text: nodeString as String).parse()
            self.dropHandler(node)
        }
        // Perform additional UI updates as needed.
    }
}

protocol EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView
}

// MARK: - NoValue

extension EIAST.NoValue: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = "No Value"
        label.textColor = EVTheme.Colors.foreground
        
        let cardView = EVProjectionalNodeView(node: self, view: label, padding: .zero, isStore: isStore)
        return cardView
    }
}

// MARK: - Integer

extension EIAST.Integer: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = value.description
        label.textColor = EVTheme.Colors.number

        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
}

// MARK: - FloatingPoint

extension EIAST.FloatingPoint: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = value.description
        label.textColor = EVTheme.Colors.number
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
}

// MARK: - Boolean

extension EIAST.Boolean: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = description
        label.textColor = EVTheme.Colors.reserved
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
}

// MARK: - BinaryOp

extension EIAST.BinaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)

        stackView.axis = .horizontal
        stackView.alignment = .leading

        guard let leftOperandNode = leftOperand as? EVProjectionalNode else {
            return EIAST.NoValue().getUIView(isStore: isStore)
        }
        guard let rightOperandNode = rightOperand as? EVProjectionalNode else {
            return EIAST.NoValue().getUIView(isStore: isStore)
        }
        
        let leftOperandView = leftOperandNode.getUIView(isStore: isStore)
        let rightOperandView = rightOperandNode.getUIView(isStore: isStore)
        if !isStore {
            leftOperandView.addTapCallback {
                numberMenu(view: cardView, numberHandler: { number in
                    self.leftOperand = number
                    EVEditor.shared.astToSourceCode()
                    EVEditor.shared.closeNodeMenu()
                    leftOperandView.unhighlight()
                })
                leftOperandView.highlight()
            }
            rightOperandView.addTapCallback {
                numberMenu(view: cardView, numberHandler: { number in
                    self.rightOperand = number
                    EVEditor.shared.astToSourceCode()
                    EVEditor.shared.closeNodeMenu()
                    rightOperandView.unhighlight()
                })
                rightOperandView.highlight()
            }
        }

        stackView.addArrangedSubview(leftOperandView)
        stackView.addArrangedSubview(getOperandView())
        stackView.addArrangedSubview(rightOperandView)
        
        return cardView
    }

    func getOperandView() -> UIView {
        let label = UILabel()
        label.text = type.rawValue
        label.textColor = EVTheme.Colors.foreground
        label.font = EVTheme.Fonts.editor?.withSize(20)
        return label
    }
    
    func handleLeftOperandDrop(node: EINode) {
        leftOperand = node
        EVEditor.shared.astToSourceCode()
    }
    
    func handleRightOperandDrop(node: EINode) {
        rightOperand = node
        EVEditor.shared.astToSourceCode()
    }
}

// MARK: - UnaryOp

extension EIAST.UnaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - Variable

extension EIAST.Variable: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = name
        label.textColor = EVTheme.Colors.identifier

        let cardView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - Function

extension EIAST.Function: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading

        let parameterView = UILabel()
        parameterView.text = "\\\(parameter) -> "
        parameterView.textColor = EVTheme.Colors.secondaryHighlighted

        stackView.addArrangedSubview(parameterView)
        let bodyNode = body as! EVProjectionalNode
        stackView.addArrangedSubview(bodyNode.getUIView(isStore: isStore))
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - FunctionApplication

extension EIAST.FunctionApplication: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        switch functionApplicationType {
        case .LeftArrow:
            return normalForm(isStore: isStore)
        case .RightArrow:
            return arrowForm(isStore: isStore)
        case .Normal:
            return normalForm(isStore: isStore)
        }
    }
    
    func normalForm(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 10
        let functionNode = function as! EVProjectionalNode
        let argumentNode = argument as! EVProjectionalNode
        
        let leftBracket = UILabel()
        leftBracket.text = "("
        leftBracket.textColor = EVTheme.Colors.symbol

        stackView.addArrangedSubview(leftBracket)
        
        let functionNodeView = functionNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(functionNodeView)
        
        let argumentNodeView = argumentNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(argumentNodeView)
        
        if !isStore {
            if argumentNode is EIAST.FloatingPoint {
                argumentNodeView.addTapCallback {
                    numberMenu(view: cardView, numberHandler: { number in
                        self.argument = number
                        EVEditor.shared.astToSourceCode()
                        EVEditor.shared.closeNodeMenu()
                        argumentNodeView.unhighlight()
                    })
                    argumentNodeView.highlight()
                }
            }
        }

        let rightBracket = UILabel()
        rightBracket.text = ")"
        rightBracket.textColor = EVTheme.Colors.symbol

        stackView.addArrangedSubview(rightBracket)
        
        return cardView
    }
    
    func arrowForm(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), isStore: isStore)
        stackView.axis = .vertical
        stackView.alignment = .leading
        let functionNode = function as! EVProjectionalNode
        let argumentNode = argument as! EVProjectionalNode
        
        let argumentNodeView = argumentNode.getUIView(isStore: isStore)
        argumentNodeView.addTapCallback {
            shapeMenu(view: cardView) { shape in
                self.argument = shape
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
            argumentNodeView.highlight()
        }
        stackView.addArrangedSubview(argumentNodeView)
        
        let functionStackView = UIStackView()
        functionStackView.axis = .horizontal
        functionStackView.alignment = .leading
        functionStackView.spacing = 5
        
        let arrow = UILabel()
        arrow.textColor = EVTheme.Colors.symbol
        arrow.text = "|>"
        functionStackView.addArrangedSubview(arrow)
        
        let functionNodeView = functionNode.getUIView(isStore: isStore)
        functionStackView.addArrangedSubview(functionNodeView)
        
        if !isStore {
            let addButton = _getAddFunctionButton(rootView: cardView)
            functionStackView.addArrangedSubview(addButton)
        }

        stackView.addArrangedSubview(functionStackView)
        
        return cardView
    }
    
    func _getAddFunctionButton(rootView: EVProjectionalNodeView) -> UIButton {
        let button = ButtonWithProjectionalViewArg()
        button.rootView = rootView
        button.setTitle("+ Add Function", for: .normal)
        button.setTitleColor(EVTheme.Colors.ProjectionalEditor.action, for: .normal)
        button.addTarget(self, action: #selector(_handleAddFunctionPress), for: .touchUpInside)
        return button
    }
    
    @objc func _handleAddFunctionPress(sender: UIButton) {
        guard let button = sender as? ButtonWithProjectionalViewArg else { return }
        let moveNode = compileNode(sourceCode: """
            move (0.0, 0.0, 0.0)
        """)
        let moveOption = EVNodeMenuOption(node: moveNode as! EVProjectionalNode, description: "Move the shape given x, y, z values") {
            self.argument = EIAST.FunctionApplication(function: self.function, argument: self.argument, functionApplicationType: .RightArrow)
            self.function = moveNode
            button.rootView?.unhighlight()
            EVEditor.shared.astToSourceCode()
            EVEditor.shared.closeNodeMenu()
        }
        let scaleNode = compileNode(sourceCode: """
            scale (1.0, 1.0, 1.0)
        """)
        let scaleOption = EVNodeMenuOption(node: scaleNode as! EVProjectionalNode, description: "Scale the shape given x, y, z values") {
            self.argument = EIAST.FunctionApplication(function: self.function, argument: self.argument, functionApplicationType: .RightArrow)
            self.function = scaleNode
            button.rootView?.unhighlight()
            EVEditor.shared.astToSourceCode()
            EVEditor.shared.closeNodeMenu()
        }
        
        let rotateNode = compileNode(sourceCode: """
            rotate (0.0, 0.0, 0.0)
        """)
        let rotateOption = EVNodeMenuOption(node: rotateNode as! EVProjectionalNode, description: "Rotate the shape given x, y, z values") {
            self.argument = EIAST.FunctionApplication(function: self.function, argument: self.argument, functionApplicationType: .RightArrow)
            self.function = rotateNode
            button.rootView?.unhighlight()
            EVEditor.shared.astToSourceCode()
            EVEditor.shared.closeNodeMenu()
        }
        
        EVEditor.shared.openNodeMenu(
            title: "Apply another function:",
            options: [moveOption, scaleOption, rotateOption]
        )
        button.rootView?.highlight()
    }
}

// MARK: - Declaration

extension EIAST.Declaration: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        
        let nameView = UILabel()
        nameView.text = name + " = "
        nameView.textColor = EVTheme.Colors.highlighted

        stackView.addArrangedSubview(nameView)
        let bodyNode = body as! EVProjectionalNode
        let bodyNodeView = bodyNode.getUIView(isStore: isStore)
        
        stackView.addArrangedSubview(bodyNodeView)
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - ConstructorInstance

extension EIAST.ConstructorInstance: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading

        let constructorNameView = EIAST.Integer(1).getUIView(isStore: isStore)
        stackView.addArrangedSubview(constructorNameView)

        for parameter in parameters {
            let parameterNode = parameter as! EVProjectionalNode
            stackView.addArrangedSubview(parameterNode.getUIView(isStore: isStore))
        }
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - Tuple

extension EIAST.Tuple: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)

        stackView.axis = .horizontal
        stackView.alignment = .leading

        let openBracket = UILabel()
        openBracket.textColor = EVTheme.Colors.symbol
        openBracket.text = "("
        let closeBracket = UILabel()
        closeBracket.textColor = EVTheme.Colors.symbol
        closeBracket.text = ")"
        
        stackView.addArrangedSubview(openBracket)
        
        for (index, v) in [v1, v2, v3].enumerated() {
            guard let vNode = v as? EVProjectionalNode else { break }
            let vNodeView = vNode.getUIView(isStore: isStore)
            if !isStore {
                vNodeView.addTapCallback {
                    numberMenu(view: cardView, numberHandler: { num in
                        if index == 0 {
                            self.v1 = num
                        } else if index == 1 {
                            self.v2 = num
                        } else if index == 2 {
                            self.v3 = num
                        }
                        EVEditor.shared.astToSourceCode()
                        EVEditor.shared.closeNodeMenu()
                        vNodeView.unhighlight()
                    })
                    vNodeView.highlight()
                }
            }
 
            stackView.addArrangedSubview(vNodeView)
            if index == 2 { break }
            
            let commaView = UILabel()
            commaView.text = ","
            commaView.textColor = EVTheme.Colors.symbol
            stackView.addArrangedSubview(commaView)
        }
        stackView.addArrangedSubview(closeBracket)
        return cardView
    }
}

// MARK: - List

extension EIAST.List: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        
        let openBracket = UILabel()
        openBracket.text = "["
        openBracket.textColor = EVTheme.Colors.symbol
        stackView.addArrangedSubview(openBracket)
        
        for (index, node) in items.enumerated() {
            let itemView = UIStackView()
            itemView.axis = .horizontal
            itemView.alignment = .trailing
            itemView.spacing = 5
            
            let leadingSpace = UIView()
            leadingSpace.frame = CGRect(x: 0, y: 0, width: 100, height: 1)
            itemView.addSubview(leadingSpace)
            
            let projectionalNode = node as! EVProjectionalNode
            let projectionalNodeView = projectionalNode.getUIView(isStore: isStore)
            itemView.addArrangedSubview(projectionalNodeView)
            
            let comma = UILabel()
            comma.text = ","
            comma.textColor = EVTheme.Colors.symbol

            itemView.addArrangedSubview(comma)
            
            let editButton = ButtonWithProjectionalViewArg()
            editButton.rootView = projectionalNodeView
            editButton.tag = index
            editButton.setTitle("Edit list item", for: .normal)
            editButton.setTitleColor(EVTheme.Colors.ProjectionalEditor.action, for: .normal)
            editButton.addTarget(self, action: #selector(handleEditItemPress), for: .touchUpInside)
            itemView.addArrangedSubview(editButton)
            
            stackView.addArrangedSubview(itemView)
        }
        if !isStore {
            stackView.addArrangedSubview(_getAddItemView())
        }
        let closeBracket = UILabel()
        closeBracket.text = "]"
        closeBracket.textColor = EVTheme.Colors.symbol

        stackView.addArrangedSubview(closeBracket)
        
        return cardView
    }
    
    func _getAddItemView() -> UIView {
        let button = UIButton()
        button.setTitle(" + Add Item", for: .normal)
        button.setTitleColor(EVTheme.Colors.ProjectionalEditor.action, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddItemPress), for: .touchUpInside)
        
        return button
    }
    
    @objc func handleEditItemPress(sender: UIButton) {
        let button = sender as! ButtonWithProjectionalViewArg
        let delete = compileNode(sourceCode: "delete")
        let deleteOption = EVNodeMenuOption(
            node: delete as! EVProjectionalNode,
            description: "Delete this item"
        ) {
            self.items.remove(at: sender.tag)
            EVEditor.shared.astToSourceCode()
            EVEditor.shared.closeNodeMenu()
        }
        EVEditor.shared.openNodeMenu(title: "Edit list item", options: [deleteOption])
        
        button.rootView?.highlight()
    }
    
    @objc func handleAddItemPress(sender: UIButton) {
        let sphere = compileNode(sourceCode: """
            sphere
                |> color (rgb 1.0 1.0 1.0)
        """)

        let sphereOption = EVNodeMenuOption(
            node: sphere as! EVProjectionalNode,
            description: "A Sphere",
            callback: {
                self.items.append(sphere)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
        )
        
        let cylinder = compileNode(sourceCode: """
            cylinder
                |> color (rgb 1.0 1.0 1.0)
        """)
        
        let cylinderOption = EVNodeMenuOption(
            node: cylinder as! EVProjectionalNode,
            description: "A Cylinder",
            callback: {
                self.items.append(cylinder)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
        )
        
        let cube = compileNode(sourceCode: """
            cube
                |> color (rgb 1.0 1.0 1.0)
        """)
        
        let cubeOption = EVNodeMenuOption(
            node: cube as! EVProjectionalNode,
            description: "A Cube",
            callback: {
                self.items.append(cube)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
        )
        
        let cone = compileNode(sourceCode: """
            cone
                |> color (rgb 1.0 1.0 1.0)
        """)
        
        let coneOption = EVNodeMenuOption(
            node: cone as! EVProjectionalNode,
            description: "A Cone",
            callback: {
                self.items.append(cone)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
        )
        
        let capsule = compileNode(sourceCode: """
            capsule
                |> color (rgb 1.0 1.0 1.0)
        """)
        
        let capsuleOption = EVNodeMenuOption(
            node: capsule as! EVProjectionalNode,
            description: "A Capsule",
            callback: {
                self.items.append(capsule)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
        )
        
        let variable = compileNode(sourceCode: """
            variable
        """)
        
        let variableOption = EVNodeMenuOption(node: variable as! EVProjectionalNode, description: "Variable") {
            let alert = UIAlertController(title: "Name of variable to use: ", message: "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = ""
            }
            alert.addAction(UIAlertAction(title: "Use variable", style: .default, handler: { [weak alert] _ in
                guard let varName = alert?.textFields![0].text else { return }
                let variable = EIAST.Variable(name: varName)
                self.items.append(variable)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }))
            sender.parentViewController?.present(alert, animated: true, completion: nil)
        }
        
        var options = [
            sphereOption,
            cylinderOption,
            cubeOption,
            coneOption,
            capsuleOption,
            variableOption,
        ]
        
        for functionName in EVEditor.shared.functionNames {
            let function = compileNode(sourceCode: """
                (\(functionName) 1.0)
            """)
            
            let functionOption = EVNodeMenuOption(
                node: function as! EVProjectionalNode,
                description: "Shape Given Time Function"
            ) {
                self.items.append(function)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            }
            options.append(functionOption)
        }
        
        EVEditor.shared.openNodeMenu(
            title: "Add item to list:",
            options: options
        )
    }
}

// MARK: - ConstructorDefinition

extension EIAST.ConstructorDefinition: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

// MARK: - TypeDefinition

extension EIAST.TypeDefinition: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: - numberMenu

func numberMenu(view: UIView, numberHandler: @escaping (EINode) -> Void) {
    let floatNum = compileNode(sourceCode: """
        1.0
    """)
    
    let floatNumOption = EVNodeMenuOption(
        node: floatNum as! EVProjectionalNode,
        description: "A number represented as a float",
        callback: {
            let alert = UIAlertController(title: "Set number: ", message: "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.keyboardType = .numberPad
                textField.text = "1.0"
            }
            alert.addAction(UIAlertAction(title: "Replace Value", style: .default, handler: { [weak alert] _ in
                guard let newValueStr = alert?.textFields![0].text else { return }
                guard let newValue = Float(newValueStr) else { return }
                let floatNode = EIAST.FloatingPoint(newValue)
                numberHandler(floatNode)
            }))
            view.parentViewController?.present(alert, animated: true, completion: nil)
        }
    )
    
    let addition = compileNode(sourceCode: """
        1.0+1.0
    """)
    
    let additionOption = EVNodeMenuOption(
        node: addition as! EVProjectionalNode,
        description: "Addition Expression",
        callback: { numberHandler(addition) }
    )
    
    let subtraction = compileNode(sourceCode: """
        1.0-1.0
    """)
    
    let subtractionOption = EVNodeMenuOption(
        node: subtraction as! EVProjectionalNode,
        description: "Subtraction Expression",
        callback: { numberHandler(subtraction) }
    )
    
    let multiplication = compileNode(sourceCode: """
        1.0*1.0
    """)
    
    let multiplicationOption = EVNodeMenuOption(
        node: multiplication as! EVProjectionalNode,
        description: "Multiplication Expression",
        callback: { numberHandler(multiplication) }
    )
    
    let division = compileNode(sourceCode: """
        1.0/1.0
    """)
    
    let divisionOption = EVNodeMenuOption(
        node: division as! EVProjectionalNode,
        description: "Division Expression",
        callback: { numberHandler(division) }
    )
    
    let sin = compileNode(sourceCode: """
        Sin(1.0)
    """)
        
    let sinOption = EVNodeMenuOption(
        node: sin as! EVProjectionalNode,
        description: "Sin Expression",
        callback: { numberHandler(sin) }
    )
    
    let cos = compileNode(sourceCode: """
        Cos(1.0)
    """)
    
    let cosOption = EVNodeMenuOption(
        node: cos as! EVProjectionalNode,
        description: "Cos Expression",
        callback: { numberHandler(cos) }
    )
    
    let tan = compileNode(sourceCode: """
        Tan(1.0)
    """)
    
    let tanOption = EVNodeMenuOption(
        node: tan as! EVProjectionalNode,
        description: "Cos Expression",
        callback: { numberHandler(tan) }
    )
    
    let degToRad = compileNode(sourceCode: """
        degToRad(1.0)
    """)
    
    let degToRadOption = EVNodeMenuOption(
        node: degToRad as! EVProjectionalNode,
        description: "Convert Degrees to Radians",
        callback: { numberHandler(degToRad) }
    )
    
    let time = compileNode(sourceCode: """
        time
    """)
    
    let timeOption = EVNodeMenuOption(
        node: time as! EVProjectionalNode,
        description: "Time Value",
        callback: { numberHandler(time) }
    )
    
    var options = [
        floatNumOption,
        additionOption,
        subtractionOption,
        divisionOption,
        multiplicationOption,
        sinOption,
        cosOption,
        tanOption,
        degToRadOption,
        timeOption,
    ]
    
    for variable in EVEditor.shared.variableNames {
        let variableNode = compileNode(sourceCode: """
            \(variable)
        """)
        
        let variableNodeOption = EVNodeMenuOption(
            node: variableNode as! EVProjectionalNode, description: "Variable"
        ) {
            numberHandler(variableNode)
        }
        options.append(variableNodeOption)
    }
    
    EVEditor.shared.openNodeMenu(
        title: "Edit number:",
        options: options
    )
}

class ButtonWithProjectionalViewArg: UIButton {
    var rootView: EVProjectionalNodeView?
}

// MARK: - shapeMenu

func shapeMenu(view: UIView, shapeHandler: @escaping (EINode) -> Void) {
    let sphere = compileNode(sourceCode: "sphere")
    let cube = compileNode(sourceCode: "cube")
    let cylinder = compileNode(sourceCode: "cylinder")
    let capsule = compileNode(sourceCode: "capsule")
    
    let sphereOption = EVNodeMenuOption(
        node: sphere as! EVProjectionalNode,
        description: "Sphere",
        callback: {
            shapeHandler(sphere)
        }
    )
    let cubeOption = EVNodeMenuOption(
        node: cube as! EVProjectionalNode,
        description: "Cube",
        callback: {
            shapeHandler(cube)
        }
    )
    let cylinderOption = EVNodeMenuOption(
        node: cylinder as! EVProjectionalNode,
        description: "Cylinder",
        callback: {
            shapeHandler(cylinder)
        }
    )
    let capsuleOption = EVNodeMenuOption(
        node: capsule as! EVProjectionalNode,
        description: "Capsule",
        callback: {
            shapeHandler(capsule)
        }
    )
    
    EVEditor.shared.openNodeMenu(title: "Select a shape:", options: [
        sphereOption,
        cubeOption,
        cylinderOption,
        capsuleOption,
    ])
}
