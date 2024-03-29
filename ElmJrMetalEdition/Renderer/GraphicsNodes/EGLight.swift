//
//  EGLight.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-13.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

typealias EGMathNode3 = (x: EGMathNode, y: EGMathNode, z: EGMathNode)

class EGLight {
    var light = Light()
    func evaluate(sceneProps: EGSceneProps) -> Light { return light }
}

class EGDirectionaLight: EGLight {
    var color: EGMathNode3
    var position: EGMathNode3
    var intensity: EGMathNode
    var specularColor: EGMathNode3

    init(color: EGMathNode3, position: EGMathNode3, intensity: EGMathNode, specularColor: EGMathNode3) {
        self.color = color
        self.position = position
        self.intensity = intensity
        self.specularColor = specularColor
        super.init()
        light.type = Directional
    }

    override func evaluate(sceneProps: EGSceneProps) -> Light {
        light.color = [
            color.x.evaluate(sceneProps),
            color.y.evaluate(sceneProps),
            color.z.evaluate(sceneProps),
        ]
        light.position = [
            position.x.evaluate(sceneProps),
            position.y.evaluate(sceneProps),
            position.z.evaluate(sceneProps),
        ]
        light.intensity = intensity.evaluate(sceneProps)
        light.specularColor = [
            specularColor.x.evaluate(sceneProps),
            specularColor.y.evaluate(sceneProps),
            specularColor.z.evaluate(sceneProps),
        ]
        return light
    }
}

class EGAmbientLight: EGLight {
    var color: EGMathNode3
    var intensity: EGMathNode

    init(color: EGMathNode3, intensity: EGMathNode) {
        self.color = color
        self.intensity = intensity
        super.init()
        light.type = Ambient
    }

    override func evaluate(sceneProps: EGSceneProps) -> Light {
        light.color = [
            color.x.evaluate(sceneProps),
            color.y.evaluate(sceneProps),
            color.z.evaluate(sceneProps),
        ]
        light.intensity = intensity.evaluate(sceneProps)
        return light
    }
}

class EGPointLight: EGLight {
    var color: EGMathNode3
    var position: EGMathNode3
    var attenuation: EGMathNode3

    init(color: EGMathNode3, position: EGMathNode3, attenuation: EGMathNode3) {
        self.color = color
        self.position = position
        self.attenuation = attenuation
        super.init()
        light.type = Point
    }

    override func evaluate(sceneProps: EGSceneProps) -> Light {
        light.color = [
            color.x.evaluate(sceneProps),
            color.y.evaluate(sceneProps),
            color.z.evaluate(sceneProps),
        ]
        light.position = [
            position.x.evaluate(sceneProps),
            position.y.evaluate(sceneProps),
            position.z.evaluate(sceneProps),
        ]
        light.attenuation = [
            attenuation.x.evaluate(sceneProps),
            attenuation.y.evaluate(sceneProps),
            attenuation.z.evaluate(sceneProps),
        ]
        return light
    }
}

class EGSpotLight: EGLight {
    var color: EGMathNode3
    var position: EGMathNode3
    var attenuation: EGMathNode3
    var coneAngle: EGMathNode
    var coneDirection: EGMathNode3
    var coneAttenuation: EGMathNode

    init(color: EGMathNode3, position: EGMathNode3, attenuation: EGMathNode3, coneAngle: EGMathNode, coneDirection: EGMathNode3, coneAttenuation: EGMathNode) {
        self.color = color
        self.position = position
        self.attenuation = attenuation
        self.coneAngle = coneAngle
        self.coneDirection = coneDirection
        self.coneAttenuation = coneAttenuation
        super.init()
        light.type = Spotlight
    }

    override func evaluate(sceneProps: EGSceneProps) -> Light {
        light.color = [
            color.x.evaluate(sceneProps),
            color.y.evaluate(sceneProps),
            color.z.evaluate(sceneProps),
        ]
        light.position = [
            position.x.evaluate(sceneProps),
            position.y.evaluate(sceneProps),
            position.z.evaluate(sceneProps),
        ]
        light.attenuation = [
            attenuation.x.evaluate(sceneProps),
            attenuation.y.evaluate(sceneProps),
            attenuation.z.evaluate(sceneProps),
        ]
        light.coneAngle = coneAngle.evaluate(sceneProps)
        light.coneDirection = [
            coneDirection.x.evaluate(sceneProps),
            coneDirection.y.evaluate(sceneProps),
            coneDirection.z.evaluate(sceneProps),
        ]
        light.coneAttenuation = coneAttenuation.evaluate(sceneProps)

        return light
    }
}
