//
//  EVDraggableDividerView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVDraggableDivider: UIView {
    
    var positionAtDragStart: CGFloat = 0
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .darkGray
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDivider))
        addGestureRecognizer(panRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func panDivider(_ recognizer : UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        if (recognizer.state == UIGestureRecognizer.State.began){
            positionAtDragStart = EVEditor.shared.textEditorWidth
        } else {
            EVEditor.shared.setTextEditorWidth(positionAtDragStart + translation.x)
        }
    }
}
