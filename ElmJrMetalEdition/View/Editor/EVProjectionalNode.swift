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
    
    init(view: UIView, borderColor: UIColor) {
        super.init(frame: .zero)
        innerView = view
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol EVProjectionalNode {
    func getUIView() -> UIView
}

extension EIParser.Integer: EVProjectionalNode {
    func getUIView() -> UIView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer
            
        let nodeView = EVProjectionalNodeView(view: label, borderColor: EVTheme.Colors.ProjectionalEditor.integer!)

        return nodeView
    }
}

extension EIParser.FloatingPoint: EVProjectionalNode {
    func getUIView() -> UIView {
        let label = UILabel()
        label.text = self.value.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.integer
            
        let nodeView = EVProjectionalNodeView(view: label, borderColor: EVTheme.Colors.ProjectionalEditor.integer!)

        return nodeView
    }
}

extension EIParser.Boolean: EVProjectionalNode {
    func getUIView() -> UIView {
        let label = UILabel()
        label.text = self.description
        label.textColor = EVTheme.Colors.ProjectionalEditor.boolean
            
        let nodeView = EVProjectionalNodeView(view: label, borderColor: EVTheme.Colors.ProjectionalEditor.boolean!)

        return nodeView
    }
}

extension EIParser.BinaryOp: EVProjectionalNode {
    func getUIView() -> UIView {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        guard let leftOperandNode = self.leftOperand as? EVProjectionalNode else { return UIView() }
        guard let rightOperandNode = self.rightOperand as? EVProjectionalNode else { return UIView() }

        stackView.addArrangedSubview(leftOperandNode.getUIView())
        stackView.addArrangedSubview(self.getOperandView())
        stackView.addArrangedSubview(rightOperandNode.getUIView())
        stackView.spacing = EVProjectionalNodeView.padding
        
        let cardView = EVProjectionalNodeView(view: stackView, borderColor: EVTheme.Colors.ProjectionalEditor.binaryOp!)

        return cardView
    }

    func getOperandView() -> UIView {
        let label = UILabel()
        label.text = self.type.rawValue
        label.textColor = EVTheme.Colors.foreground
        label.font = EVTheme.Fonts.editor?.withSize(20)
        return label
    }
}

extension EIParser.UnaryOp: EVProjectionalNode {
    func getUIView() -> UIView {
        let cardView = EVProjectionalNodeView(view: UIView(), borderColor: .red)
        return cardView
    }
}
