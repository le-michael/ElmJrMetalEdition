//
//  RMTrig.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

enum TrigOp {
    case sin
    case cos
    case tan
}

class RMTrig: RMNode {
    let type: TrigOp
    let child: RMNode

    init(type: TrigOp, child: RMNode) {
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
