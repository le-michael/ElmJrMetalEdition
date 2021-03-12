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
    var tapHandler: ()->() = {}
    var dropHandler: (EINode)->() = {node in}
    var node: EINode!
    
    init(node: EINode, view: UIView, padding: UIEdgeInsets, isStore: Bool = false) {
        super.init(frame: .zero)
        innerView = view
        self.isStore = isStore
        self.node = node
        addSubview(innerView)

        backgroundColor = EVTheme.Colors.background
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 5;
        layer.masksToBounds = true;
        
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
    
    func addTapCallback(callback: @escaping ()->Void) {
        tapHandler = callback
        setupTapGesture()
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
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
        layer.borderColor = UIColor.yellow.cgColor
    }
    
    func unhighlight() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("Tapped")
        tapHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EIAST.NoValue: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = "No Value"
        label.textColor = EVTheme.Colors.foreground
        
        let cardView = EVProjectionalNodeView(node: self, view: label, padding: .zero, isStore: isStore)
        return cardView
    }
}

extension EVProjectionalNodeView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let stringItemProvider = NSItemProvider(object: node.description as NSString)
        return [UIDragItem(itemProvider: stringItemProvider)]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
    }
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

extension EIAST.Integer: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer

        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
    
    
}

extension EIAST.FloatingPoint: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
}

extension EIAST.Boolean: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = self.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.boolean
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)

        return nodeView
    }
}

extension EIAST.BinaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)

        stackView.axis = .horizontal
        stackView.alignment = .leading

        
        guard let leftOperandNode = self.leftOperand as? EVProjectionalNode else {
            return EIAST.NoValue().getUIView(isStore: isStore)
        }
        guard let rightOperandNode = self.rightOperand as? EVProjectionalNode else {
            return EIAST.NoValue().getUIView(isStore: isStore)
        }
        
        let leftOperandView = leftOperandNode.getUIView(isStore: isStore)
        let rightOperandView = rightOperandNode.getUIView(isStore: isStore)
        if !isStore {
            leftOperandView.addTapCallback {
                leftOperandView.highlight()
                numberMenu(view: cardView, numberHandler: {number in
                    self.leftOperand = number
                    EVEditor.shared.astToSourceCode()
                    EVEditor.shared.closeNodeMenu()
                    leftOperandView.unhighlight()
                })
            }
            rightOperandView.addTapCallback {
                rightOperandView.highlight()
                numberMenu(view: cardView, numberHandler: {number in
                    self.rightOperand = number
                    EVEditor.shared.astToSourceCode()
                    EVEditor.shared.closeNodeMenu()
                    rightOperandView.unhighlight()
                })
            }
        }

        stackView.addArrangedSubview(leftOperandView)
        stackView.addArrangedSubview(self.getOperandView())
        stackView.addArrangedSubview(rightOperandView)
                

        return cardView
    }

    func getOperandView() -> UIView {
        let label = UILabel()
        label.text = self.type.rawValue
        label.textColor = EVTheme.Colors.foreground
        label.font = EVTheme.Fonts.editor?.withSize(20)
        return label
    }
    
    func handleLeftOperandDrop(node: EINode) {
        self.leftOperand = node
        EVEditor.shared.astToSourceCode()
    }
    
    func handleRightOperandDrop(node: EINode) {
        self.rightOperand = node
        EVEditor.shared.astToSourceCode()
    }
}

extension EIAST.UnaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

extension EIAST.Variable: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = name
        let cardView = EVProjectionalNodeView(node: self, view: label, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

extension EIAST.Function: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading

        let parameterView = UILabel()
        parameterView.text = parameter + " -> "
        stackView.addArrangedSubview(parameterView)
        let bodyNode = body as! EVProjectionalNode
        stackView.addArrangedSubview(bodyNode.getUIView(isStore: isStore))
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

extension EIAST.FunctionApplication: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        return normalForm(isStore: isStore)
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
        stackView.addArrangedSubview(leftBracket)
        
        let functionNodeView = functionNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(functionNodeView)
        
        let argumentNodeView = argumentNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(argumentNodeView)
        
        if !isStore {
            if let argumentNumber = argumentNode as? EIAST.FloatingPoint {
                argumentNodeView.addTapCallback {
                    argumentNodeView.highlight()
                    numberMenu(view: cardView, numberHandler: {number in
                        self.argument = number
                        EVEditor.shared.astToSourceCode()
                        EVEditor.shared.closeNodeMenu()
                        argumentNodeView.unhighlight()
                    })
                }
            }
        }

        
        let rightBracket = UILabel()
        rightBracket.text = ")"
        stackView.addArrangedSubview(rightBracket)
        
        return cardView
    }
    
    func arrowForm(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        let functionNode = function as! EVProjectionalNode
        let argumentNode = argument as! EVProjectionalNode
        
        let argumentNodeView = argumentNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(argumentNodeView)
        
        let functionStackView = UIStackView()
        functionStackView.axis = .horizontal
        functionStackView.alignment = .leading
        
        let arrow = UILabel()
        arrow.text = "|>"
        
        
        let functionNodeView = functionNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(functionNodeView)
        

        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)
        return cardView
    }
}

extension EIAST.Declaration: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        
        let nameView = UILabel()
        nameView.text = name + " = "
        stackView.addArrangedSubview(nameView)
        let bodyNode = body as! EVProjectionalNode
        let bodyNodeView = bodyNode.getUIView(isStore: isStore)
        
        stackView.addArrangedSubview(bodyNodeView)
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

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

extension EIAST.Tuple: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), isStore: isStore)

        stackView.axis = .horizontal
        stackView.alignment = .leading

        let openBracket = UILabel()
        openBracket.text = "("
        let closeBracket = UILabel()
        closeBracket.text = ")"
        
        stackView.addArrangedSubview(openBracket)
        
        for (index, v) in [v1, v2, v3].enumerated() {
 
            guard let vNode = v as? EVProjectionalNode else { break }
            let vNodeView = vNode.getUIView(isStore: isStore)
            vNodeView.addTapCallback {
                vNodeView.highlight()
                numberMenu(view:cardView, numberHandler: {num in
                    if (index == 0) {
                        self.v1 = num
                    } else if (index == 1) {
                        self.v2 = num
                    } else if (index == 3) {
                        self.v3 = num
                    }
                    EVEditor.shared.astToSourceCode()
                    EVEditor.shared.closeNodeMenu()
                    vNodeView.unhighlight()
                })
            }
            stackView.addArrangedSubview(vNodeView)
            if (index == 2) { break }
            
            let commaView = UILabel()
            commaView.text = ","
            stackView.addArrangedSubview(commaView)
        }
        stackView.addArrangedSubview(closeBracket)
        return cardView
    }
}

extension EIAST.List: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        
        let openBracket = UILabel()
        openBracket.text = "["
        stackView.addArrangedSubview(openBracket)
        
        for node in items {
            let itemView = UIStackView()
            itemView.axis = .horizontal
            itemView.alignment = .trailing
            
            let leadingSpace = UIView()
            leadingSpace.frame = CGRect(x: 0, y: 0, width: 100, height: 1)
            itemView.addSubview(leadingSpace)
            
            let projectionalNode = node as! EVProjectionalNode
            itemView.addArrangedSubview(projectionalNode.getUIView(isStore: isStore))
            
            let comma = UILabel()
            comma.text = ","
            itemView.addArrangedSubview(comma)
            
            stackView.addArrangedSubview(itemView)
        }
        if (!isStore) {
            stackView.addArrangedSubview(_getAddItemView())
        }
        let closeBracket = UILabel()
        closeBracket.text = "]"
        stackView.addArrangedSubview(closeBracket)
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
    
    func _getAddItemView() -> UIView {
        let button = UIButton()
        button.setTitle(" + Add Item", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddItemPress), for: .touchUpInside)
        
        return button
    }
    
    @objc func handleAddItemPress(sender: UIButton) {
        
        
        let sphere = compileNode(sourceCode: """
            sphere
                |> color (rgb 1.0 1.0 1.0)
                |> move (0.0, 0.0, 0.0)
                |> scale (1.0, 1.0, 1.0)
        """)

        let sphereOption = EVNodeMenuOption(
            node: sphere as! EVProjectionalNode,
            description: "A Sphere",
            callback: {
                self.items.append(sphere)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            })
        
        let cylinder = compileNode(sourceCode: """
            cylinder
                |> color (rgb 1.0 1.0 1.0)
                |> move (0.0, 0.0, 0.0)
                |> scale (1.0, 1.0, 1.0)
        """)
        
        let cylinderOption = EVNodeMenuOption(
            node: cylinder as! EVProjectionalNode,
            description: "A Cylinder",
            callback: {
                self.items.append(cylinder)
                EVEditor.shared.astToSourceCode()
                EVEditor.shared.closeNodeMenu()
            })
        

        
        EVEditor.shared.openNodeMenu(
            title: "Add item to list:",
            options: [sphereOption, cylinderOption]
        )
    }
}

extension EIAST.ConstructorDefinition: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), isStore: isStore)
        return cardView
    }
}

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

func numberMenu(view: UIView, numberHandler: @escaping (EINode)->Void) {
    
    let floatNum = compileNode(sourceCode: """
        1.0
    """)
    
    let floatNumOption = EVNodeMenuOption(
        node: floatNum as! EVProjectionalNode,
        description: "A number represented as a float",
        callback: {
            let alert = UIAlertController(title: "Set number: ", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.text = "1.0"
            }
            alert.addAction(UIAlertAction(title: "Replace Value", style: .default, handler: { [weak alert] (_) in
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
        description: "Addition Binary Expression",
        callback: { numberHandler(addition) }
    )
    
    let sin = compileNode(sourceCode: """
        Sin(1.0)
    """)
        
    let sinOption = EVNodeMenuOption(
        node: sin as! EVProjectionalNode,
        description: "Sin Expression",
        callback: { numberHandler(sin) }
    )
    
    let time = compileNode(sourceCode: """
        time
    """)
    
    let timeOption = EVNodeMenuOption(
        node: time as! EVProjectionalNode,
        description: "Time Value",
        callback: { numberHandler(time) }
    )
    
    EVEditor.shared.openNodeMenu(
        title: "Edit number:",
        options: [floatNumOption, additionOption, sinOption, timeOption]
    )
}

