//
//  EVButtonCell.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-04.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVButtonCell: UICollectionViewCell {
        
    var project: EVProject?
    var callback: ()->() = {}
    let button = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.titleLabel?.textColor = EVTheme.Colors.foreground
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func setTitle(title: String) {
        button.setTitle(title, for: .normal)
    }
    
    @objc func buttonPressed(){
        self.callback()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
