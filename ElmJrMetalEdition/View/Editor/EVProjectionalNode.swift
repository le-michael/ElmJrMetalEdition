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
    var borderColor: UIColor!
    var isStore: Bool!
    var tapHandler: ()->() = {}
    var dropHandler: (EINode)->() = {node in}
    var node: EINode!
    
    init(node: EINode, view: UIView, borderColor: UIColor, isStore: Bool = false) {
        super.init(frame: .zero)
        innerView = view
        self.isStore = isStore
        self.node = node
        self.borderColor = borderColor
        addSubview(innerView)

        backgroundColor = EVTheme.Colors.background
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = 5;
        layer.masksToBounds = true;
        
        translatesAutoresizingMaskIntoConstraints = false
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.topAnchor.constraint(equalTo: topAnchor, constant: EVProjectionalNodeView.padding).isActive = true
        innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -EVProjectionalNodeView.padding).isActive = true
        innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: EVProjectionalNodeView.padding).isActive = true
        innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -EVProjectionalNodeView.padding).isActive = true
        
        setupTapGesture()
        
        if isStore {
            setupDrag()
        } else {
            setupDrop()
        }
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
        
        let cardView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.foreground!, isStore: isStore)
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

        let nodeView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.ProjectionalEditor.integer!, isStore: isStore)
        nodeView.tapHandler = {
            let alert = UIAlertController(title: "Replace value of node: ", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.text = "\(self.value)"
            }
            alert.addAction(UIAlertAction(title: "Replace Value", style: .default, handler: { [weak alert] (_) in
                guard let newValueStr = alert?.textFields![0].text else { return }
                guard let newValue = Int(newValueStr) else { return }
                self.value = newValue
                EVEditor.shared.astToSourceCode()
            }))
            let uiView = nodeView as UIView
            uiView.parentViewController?.present(alert, animated: true, completion: nil)
        }
        return nodeView
    }
    
    
}

extension EIAST.FloatingPoint: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.ProjectionalEditor.integer!, isStore: isStore)
        nodeView.tapHandler = {
            let alert = UIAlertController(title: "Replace value of node: ", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.text = "\(self.value)"
            }
            alert.addAction(UIAlertAction(title: "Replace Value", style: .default, handler: { [weak alert] (_) in
                guard let newValueStr = alert?.textFields![0].text else { return }
                guard let newValue = Float(newValueStr) else { return }
                self.value = newValue
                EVEditor.shared.astToSourceCode()
            }))
            let uiView = nodeView as UIView
            uiView.parentViewController?.present(alert, animated: true, completion: nil)
        }

        return nodeView
    }
}

extension EIAST.Boolean: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = self.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.boolean
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.ProjectionalEditor.boolean!, isStore: isStore)

        return nodeView
    }
}

extension EIAST.BinaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        let stackView = UIStackView()
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
        
        leftOperandView.dropHandler = handleLeftOperandDrop
        rightOperandView.dropHandler = handleRightOperandDrop

        stackView.addArrangedSubview(leftOperandView)
        stackView.addArrangedSubview(self.getOperandView())
        stackView.addArrangedSubview(rightOperandView)
                
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: EVTheme.Colors.ProjectionalEditor.binaryOp!, isStore: isStore)

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

// TODO NOW
extension EIAST.UnaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
extension EIAST.Variable: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let label = UILabel()
        label.text = name
        let cardView = EVProjectionalNodeView(node: self, view: label, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
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
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
extension EIAST.FunctionApplication: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        let functionNode = function as! EVProjectionalNode
        let argumentNode = argument as! EVProjectionalNode
        
        let functionNodeView = functionNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(functionNodeView)
        
        let argumentNodeView = argumentNode.getUIView(isStore: isStore)
        stackView.addArrangedSubview(argumentNodeView)
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
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
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
extension EIAST.ConstructorInstance: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading

        let constructorNameView = EIAST.Integer(1).getUIView(isStore: isStore)
        //constructorNameView.text = constructorName
        stackView.addArrangedSubview(constructorNameView)

        for parameter in parameters {
            let parameterNode = parameter as! EVProjectionalNode
            stackView.addArrangedSubview(parameterNode.getUIView(isStore: isStore))
        }
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
extension EIAST.Tuple: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading

        
        let commaView1 = UILabel()
        commaView1.text = ","
        let commaView2 = UILabel()
        commaView2.text = ","
        let openBracket = UILabel()
        openBracket.text = "("
        let closeBracket = UILabel()
        closeBracket.text = ")"
        
        stackView.addArrangedSubview(openBracket)
        let v1Node = v1 as! EVProjectionalNode
        stackView.addArrangedSubview(v1Node.getUIView(isStore: isStore))
        stackView.addArrangedSubview(commaView1)
        let v2Node = v2 as! EVProjectionalNode
        stackView.addArrangedSubview(v2Node.getUIView(isStore: isStore))
        if let v3Node = v3 as? EVProjectionalNode {
            stackView.addArrangedSubview(commaView2)
            stackView.addArrangedSubview(v3Node.getUIView(isStore: isStore))
        }
        stackView.addArrangedSubview(closeBracket)
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
        return cardView
    }
}

// TODO NOW
extension EIAST.List: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        
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
        stackView.addArrangedSubview(_getAddItemView())
        let closeBracket = UILabel()
        closeBracket.text = "]"
        stackView.addArrangedSubview(closeBracket)
        
        let cardView = EVProjectionalNodeView(node: self, view: stackView, borderColor: .red, isStore: isStore)
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
        let alert = UIAlertController(title: "Add item to list: ", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cylinder", style: .default, handler: { [weak alert] (_) in
            self.items.append(EIAST.ConstructorInstance(constructorName: "cylinder", parameters: []))
            EVEditor.shared.astToSourceCode()
        }))
        alert.addAction(UIAlertAction(title: "Sphere", style: .default, handler: { [weak alert] (_) in
            let sphere = compileNode(sourceCode: """
                sphere
                    |> color (rgb 1 1 1)
                    |> move (0, 2.25, 0)
                    |> scaleAll 0.5
            """)
            print(sphere)
            self.items.append(sphere)
            EVEditor.shared.astToSourceCode()
        }))
        let uiView = sender as UIView
        uiView.parentViewController?.present(alert, animated: true, completion: nil)
    }
}

// STUFF TO DO LATER


// TODO
extension EIAST.ConstructorDefinition: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), borderColor: .red, isStore: isStore)
        return cardView
    }
}


// TODO
extension EIAST.TypeDefinition: EVProjectionalNode {
    func getUIView(isStore: Bool) -> EVProjectionalNodeView {
        let cardView = EVProjectionalNodeView(node: self, view: UIView(), borderColor: .red, isStore: isStore)
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


