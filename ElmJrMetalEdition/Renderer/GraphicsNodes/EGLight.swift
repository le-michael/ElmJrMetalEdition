//
//  EGLight.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-13.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

class EGLight {
    static func directional(color: simd_float3, position: simd_float3, intensity: Float, specularColor: simd_float3) -> Light {
        var light = Light()
        light.position = position
        light.color = color
        light.intensity = intensity
        light.type = Directional
        light.specularColor = specularColor
        return light
    }

    static func ambient(color: simd_float3, intensity: Float) -> Light {
        var light = Light()
        light.color = color
        light.intensity = intensity
        light.type = Ambient
        return light
    }

    static func point(color: simd_float3, position: simd_float3, attenuation: simd_float3) -> Light {
        var light = Light()
        light.type = Point
        light.color = color
        light.position = position
        light.attenuation = attenuation
        return light
    }

    static func spotlight(color: simd_float3, position: simd_float3, attenuation: simd_float3, coneAngle: Float, coneDirection: simd_float3, coneAttenuation: Float) -> Light {
        var light = Light()
        light.type = Spotlight
        light.color = color
        light.position = position
        light.attenuation = attenuation
        light.coneAngle = coneAngle
        light.coneDirection = coneDirection
        light.coneAttenuation = coneAttenuation
        return light
    }
}
