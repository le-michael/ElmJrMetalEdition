//
//  TriangleEditNode.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation
import MetalKit

var mockData : [TriangleEditNode] = [
    TriangleEditNode(xPos: -0.5, yPos: 0.7, size: 0.3, rotation: 0, color: ColorEditNode(r: 1.0, g: 0.0, b:0.0, a: 1.0)),
    TriangleEditNode(xPos: -0.1, yPos: 0.5, size: 0.2, rotation: 45, color: ColorEditNode(r: 0.0, g: 1.0, b:0.0, a: 1.0)),
    TriangleEditNode(xPos: 0.3, yPos: 0.1, size: 0.5, rotation: 180, color: ColorEditNode(r: 1.0, g: 0.0, b:1.0, a: 1.0)),
    TriangleEditNode(xPos: -0.6, yPos: 0.5, size: 0.3, rotation: 0, color: ColorEditNode(r: 1.0, g: 1.0, b:0.0, a: 1.0)),
    TriangleEditNode(xPos: -0.5, yPos: 0.5, size: 0.3, rotation: 0, color: ColorEditNode(r: 0.0, g: 1.0, b:1.0, a: 1.0)),

]

class TriangleEditNode {
    
    var xPos: Float;
    var yPos: Float;
    var size: Float;
    var rotation: Float;
    var color: ColorEditNode;
    
    init(xPos: Float, yPos: Float, size: Float, rotation: Float, color: ColorEditNode) {
        self.xPos = xPos;
        self.yPos = yPos;
        self.size = size;
        self.rotation = rotation;
        self.color = color;
    }
}


