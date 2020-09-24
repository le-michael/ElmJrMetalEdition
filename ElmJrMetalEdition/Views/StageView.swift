//
//  StageView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

class StageView : UIView {
    
    let mtkView = MTKView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mtkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
    
}
