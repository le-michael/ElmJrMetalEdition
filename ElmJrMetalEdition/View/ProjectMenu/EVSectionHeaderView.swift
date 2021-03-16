//
//  EVProjectHeaderView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-04.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVSectionHeaderView: UICollectionViewCell {
    
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = EVTheme.Colors.ProjectionalEditor.action
        label.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
