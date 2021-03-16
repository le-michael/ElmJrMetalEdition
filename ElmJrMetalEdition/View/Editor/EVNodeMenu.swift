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

class EVNodeMenu: UIView, UITextFieldDelegate {
    
    var scrollView: UIScrollView!
    
    var stackView: UIStackView!
    
    var title: String = ""
    
    var searchBar: UITextField?
    
    var options: [EVNodeMenuOption] = []

    
    init(title: String, options: [EVNodeMenuOption]) {
        self.title = title
        self.options = options
        super.init(frame: .zero)
        
        backgroundColor = .clear
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        setupStackView()
    }
    
    func setupStackView() {
        scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        stackView = UIStackView()
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        let titleView = UILabel()
        stackView.addArrangedSubview(titleView)
        titleView.text = self.title
        titleView.font = UIFont.systemFont(ofSize: 24)
        stackView.setCustomSpacing(20, after: titleView)
        
        if self.options.count > 10 {
            setupSearchBar()
        }
        updateOptions()
    }
    
    func updateOptions() {
        
        if stackView.arrangedSubviews.count > 2 {
            for view in stackView.arrangedSubviews[2...] {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        
        var optionsToUse: [EVNodeMenuOption] = []
        
        if self.searchBar != nil && self.searchBar?.text != "" {
            for option in self.options {
                let optDesc = option.description.lowercased()
                let search = (self.searchBar?.text ?? "").lowercased()
                if (optDesc.contains(search)) {
                    optionsToUse.append(option)
                }
            }
        } else {
            optionsToUse = self.options
        }
        
        for option in optionsToUse {
            
            let labelView = UILabel()
            labelView.text = option.description
            stackView.addArrangedSubview(labelView)
            
            let nodeView = option.node.getUIView(isStore: true)
            nodeView.addTapCallback(callback: option.callback)
            stackView.addArrangedSubview(nodeView)
            
            stackView.setCustomSpacing(20, after: nodeView)

        }
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(_handleCancel), for: .touchUpInside)
        stackView.addArrangedSubview(cancelButton)
    }
    
    func setupSearchBar() {
        searchBar = UITextField()
        searchBar?.returnKeyType = .go
        searchBar?.delegate = self
        stackView.addArrangedSubview(searchBar!)
        searchBar?.borderStyle = .line
        searchBar?.translatesAutoresizingMaskIntoConstraints = false
        searchBar?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        searchBar?.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateOptions()
        return true
    }
    
    @objc func _handleCancel() {
        EVEditor.shared.closeNodeMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
