//
//  MathLibrary.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2021-01-08.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import simd

extension simd_float4 {
  var xyz: simd_float3 {
    get {
      simd_float3(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }
}

extension matrix_float4x4 {
    var upperLeft: float3x3 {
      let x = columns.0.xyz
      let y = columns.1.xyz
      let z = columns.2.xyz
      return float3x3(columns: (x, y, z))
    }
}
