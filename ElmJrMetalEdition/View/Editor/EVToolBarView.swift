//
//  EVToolBarView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVToolBarView: UIView {
    
    var editor: EVEditor?
    
    let navigationBar = UINavigationBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(navigationBar)
        navigationBar.backgroundColor = .white
        navigationBar.delegate = self
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Elm Project"
        
        let runButton = UIBarButtonItem(title: "Run", style: UIBarButtonItem.Style.plain, target: self, action: #selector(runClicked))
        navigationItem.rightBarButtonItem = runButton
        
        navigationBar.items = [navigationItem]

        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        navigationBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func runClicked(sender: UIBarButtonItem) {
        editor?.run()
    }
    
}

extension EVToolBarView: UINavigationBarDelegate {
    
}
