//
//  RMNode.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

protocol RMNode {
    func evaluate(_ sceneProps: SceneProps) -> Float
}
