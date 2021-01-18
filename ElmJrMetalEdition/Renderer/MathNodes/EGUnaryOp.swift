//
//  EGUnaryOp.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGUnaryOp: EGMathNode {
    enum UnaryOpType: String {
        case abs
        case neg
        case sin
        case cos
        case tan
    }

    let type: UnaryOpType
    var child: EGMathNode

    init(type: UnaryOpType, child: EGMathNode) {
        self.type = type
        self.child = child
    }

    func evaluate(_ sceneProps: EGSceneProps) -> Float {
        switch type {
        case .sin:
            return sin(child.evaluate(sceneProps))
        case .cos:
            return cos(child.evaluate(sceneProps))
        case .tan:
            return tan(child.evaluate(sceneProps))
        case .neg:
            return -child.evaluate(sceneProps)
        case .abs:
            return abs(child.evaluate(sceneProps))
        }
    }

    func usesTime() -> Bool {
        return child.usesTime()
    }
}
