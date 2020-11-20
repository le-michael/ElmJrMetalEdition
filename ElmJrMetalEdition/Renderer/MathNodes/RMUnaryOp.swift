//
//  RMTrig.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

enum UnaryOp {
    case sin
    case cos
    case tan
}

class RMUnaryOp: RMNode {
    let type: UnaryOp
    let child: RMNode

    init(type: UnaryOp, child: RMNode) {
        self.type = type
        self.child = child
    }

    override func evaluate(_ sceneProps: SceneProps) -> Float {
        switch type {
        case .sin:
            return sin(child.evaluate(sceneProps))
        case .cos:
            return cos(child.evaluate(sceneProps))
        case .tan:
            return tan(child.evaluate(sceneProps))
        }
    }
}
