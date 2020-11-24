//
//  RMBinaryOp.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

enum RMBinaryOpType {
    case add
    case sub
    case mul
    case div
}

class RMBinaryOp: RMNode {
    var type: RMBinaryOpType
    var leftChild: RMNode
    var rightChild: RMNode

    init(type: RMBinaryOpType, leftChild: RMNode, rightChild: RMNode) {
        self.type = type
        self.leftChild = leftChild
        self.rightChild = rightChild
    }

    func evaluate(_ sceneProps: SceneProps) -> Float {
        switch type {
        case .add:
            return leftChild.evaluate(sceneProps) + rightChild.evaluate(sceneProps)
        case .sub:
            return leftChild.evaluate(sceneProps) - rightChild.evaluate(sceneProps)
        case .mul:
            return leftChild.evaluate(sceneProps) * rightChild.evaluate(sceneProps)
        case .div:
            return leftChild.evaluate(sceneProps) / rightChild.evaluate(sceneProps)
        }
    }
}
