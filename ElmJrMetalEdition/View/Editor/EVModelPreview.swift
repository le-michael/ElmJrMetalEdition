//
//  ModelPreview.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-03-15.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVModelPreview: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
