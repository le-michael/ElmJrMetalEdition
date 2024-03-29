//
//  EGBinaryOp.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class EGBinaryOp: EGMathNode {
    enum BinaryOpType: String {
        case add
        case sub
        case mul
        case div
        case max
        case min
    }

    var type: BinaryOpType
    var leftChild: EGMathNode
    var rightChild: EGMathNode

    init(type: BinaryOpType, leftChild: EGMathNode, rightChild: EGMathNode) {
        self.type = type
        self.leftChild = leftChild
        self.rightChild = rightChild
    }

    func evaluate(_ sceneProps: EGSceneProps) -> Float {
        switch type {
        case .add:
            return leftChild.evaluate(sceneProps) + rightChild.evaluate(sceneProps)
        case .sub:
            return leftChild.evaluate(sceneProps) - rightChild.evaluate(sceneProps)
        case .mul:
            return leftChild.evaluate(sceneProps) * rightChild.evaluate(sceneProps)
        case .div:
            return leftChild.evaluate(sceneProps) / rightChild.evaluate(sceneProps)
        case .max:
            return max(leftChild.evaluate(sceneProps), rightChild.evaluate(sceneProps))
        case .min:
            return min(leftChild.evaluate(sceneProps), rightChild.evaluate(sceneProps))
        }
    }

    func usesTime() -> Bool {
        return leftChild.usesTime() || rightChild.usesTime()
    }
}
