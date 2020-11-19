//
//  RMTime.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-19.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

class RMTime: RMNode {
    override func evaluate(_ sceneProps: SceneProps) -> Float {
        return sceneProps.time
    }
}
