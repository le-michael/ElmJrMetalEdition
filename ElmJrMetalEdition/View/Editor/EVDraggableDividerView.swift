//
//  EVDraggableDividerView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVDraggableDivider: UIView {
    
    var dragsHorizontally: Bool
    var positionAtDragStart: CGFloat = 0
    
    init(dragsHorizontally: Bool) {
        self.dragsHorizontally = dragsHorizontally
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
            positionAtDragStart = dragsHorizontally ? EVEditor.shared.textEditorWidth : EVEditor.shared.textEditorHeight
        } else {
            let deltaPosition = dragsHorizontally ? translation.x : translation.y
            if (dragsHorizontally){
                EVEditor.shared.setTextEditorWidth(positionAtDragStart + deltaPosition)
            } else {
                EVEditor.shared.setTextEditorHeight(positionAtDragStart + deltaPosition)
            }
        }
    }
}
