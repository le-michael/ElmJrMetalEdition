//
//  EVNodeMenu.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-03-05.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVNodeMenuOption {
    
    var node: EVProjectionalNode
    var description: String
    var callback: ()->Void
    
    init(node: EVProjectionalNode, description: String, callback: @escaping ()->Void) {
        self.node = node
        self.description = description
        self.callback = callback
    }
}

class EVNodeMenu: UIView {
    
    var stackView: UIStackView!
    
    var title: String = ""
    
    var options: [EVNodeMenuOption] = []

    
    init(title: String, options: [EVNodeMenuOption]) {
        self.title = title
        self.options = options
        super.init(frame: .zero)
        
        backgroundColor = .gray
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        setupStackView()
    }
    
    func setupStackView() {
        stackView = UIStackView()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        let titleView = UILabel()
        stackView.addArrangedSubview(titleView)
        titleView.text = self.title
        
        for option in self.options {
            
            let labelView = UILabel()
            labelView.text = option.description
            stackView.addArrangedSubview(labelView)
            
            let nodeView = option.node.getUIView(isStore: true)
            nodeView.addTapCallback(callback: option.callback)
            stackView.addArrangedSubview(nodeView)
            
            stackView.setCustomSpacing(20, after: nodeView)

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
