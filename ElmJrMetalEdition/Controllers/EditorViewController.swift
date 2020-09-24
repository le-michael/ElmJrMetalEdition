//
//  EditorViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class EditorViewController : UIViewController {
    
    let stageView = StageView()
    
    override func viewDidLoad() {
        view.backgroundColor = .red
        view.addSubview(stageView)
        stageView.translatesAutoresizingMaskIntoConstraints = false
        stageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        stageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        stageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        stageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    }
    
}
