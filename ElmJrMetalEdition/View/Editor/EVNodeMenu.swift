//
//  EVNodeMenu.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-03-05.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVNodeMenu: UIView {
    
    var stackView: UIStackView!
    var nodes: [EVProjectionalNode] = []
    var descriptions: [String] = []
    var callbacks: [()->Void] = []
    
    init(nodes: [EVProjectionalNode], descriptions: [String], callbacks: [()->Void]) {
        self.nodes = nodes
        self.descriptions = descriptions
        self.callbacks = callbacks
        super.init(frame: .zero)
        setupStackView()
    }
    
    func setupStackView() {
        stackView = UIStackView()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        for (index, node) in nodes.enumerated() {
            let nodeView = node.getUIView(isStore: true)
            nodeView.addTapCallback(callback: callbacks[index])
            stackView.addArrangedSubview(nodeView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
