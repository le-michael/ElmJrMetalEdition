//
//  EVMenuView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVMenuView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = EVTheme.Colors.background
        
        let innerBinaryOp = EIParser.BinaryOp(EIParser.Integer(3), EIParser.FloatingPoint(3), .multiply)
        
        let binaryOp = EIParser.BinaryOp(EIParser.Integer(1), innerBinaryOp, .add)
        let binaryOpView = binaryOp.getUIView()
                
        addSubview(binaryOpView)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
