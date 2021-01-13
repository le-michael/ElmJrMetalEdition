//
//  EVProjectionalNode.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-08.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit


class EVProjectionalNodeView: UIView {
    
    static var padding: CGFloat = 10
    
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
        layer.borderColor = borderColor.cgColor
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
        tapHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func getUIView(isStore: Bool) -> UIView
}

extension EIParser.Integer: EVProjectionalNode {
    func getUIView(isStore: Bool) -> UIView {
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

extension EIParser.FloatingPoint: EVProjectionalNode {
    func getUIView(isStore: Bool) -> UIView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.ProjectionalEditor.integer!, isStore: isStore)

        return nodeView
    }
}

extension EIParser.Boolean: EVProjectionalNode {
    func getUIView(isStore: Bool) -> UIView {
        let label = UILabel()
        label.text = self.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.boolean
            
        let nodeView = EVProjectionalNodeView(node: self, view: label, borderColor: EVTheme.Colors.ProjectionalEditor.boolean!, isStore: isStore)

        return nodeView
    }
}

extension EIParser.BinaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> UIView {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        guard let leftOperandNode = self.leftOperand as? EVProjectionalNode else { return UIView() }
        guard let rightOperandNode = self.rightOperand as? EVProjectionalNode else { return UIView() }
        
        let leftOperandView = leftOperandNode.getUIView(isStore: isStore) as! EVProjectionalNodeView
        let rightOperandView = rightOperandNode.getUIView(isStore: isStore) as! EVProjectionalNodeView
        
        leftOperandView.dropHandler = handleLeftOperandDrop
        rightOperandView.dropHandler = handleRightOperandDrop

        stackView.addArrangedSubview(leftOperandView)
        stackView.addArrangedSubview(self.getOperandView())
        stackView.addArrangedSubview(rightOperandView)
        stackView.spacing = EVProjectionalNodeView.padding
        
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

extension EIParser.UnaryOp: EVProjectionalNode {
    func getUIView(isStore: Bool) -> UIView {
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
