//
//  EVDraggableDividerView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVDraggableDivider: UIView {
    
    var editor: EVEditor?
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
            guard let widthConstant = editor?.textEditorWidth else { return }
            guard let heightConstant = editor?.textEditorHeight else { return }
            positionAtDragStart = dragsHorizontally ? widthConstant : heightConstant
        } else {
            let deltaPosition = dragsHorizontally ? translation.x : translation.y
            if (dragsHorizontally){
                editor?.setTextEditorWidth(positionAtDragStart + deltaPosition)
            } else {
                editor?.setTextEditorHeight(positionAtDragStart + deltaPosition)
            }
        }
    }
}
