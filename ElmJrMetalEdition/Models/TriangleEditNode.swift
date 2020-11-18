//
//  TriangleEditNode.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-11-17.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import Foundation

var mockData : [TriangleEditNode] = [
    TriangleEditNode(xPos: 0, yPos: 0, size: 0.2, color: ColorEditNode(r: 1.0, g: 0.0, b: 0.0, a: 1.0)),
    TriangleEditNode(xPos: 0.4, yPos: 0.2, size: 0.2, color: ColorEditNode(r: 0.0, g: 1.0, b: 0.0, a: 1.0)),
    TriangleEditNode(xPos: -0.3, yPos: -0.4, size: 0.4, color: ColorEditNode(r: 0.0, g: 0.0, b: 1.0, a: 1.0)),
]

class TriangleEditNode {
    var xPos: Float;
    var yPos: Float;
    var size: Float;
    var color: ColorEditNode;
    
    init(xPos: Float, yPos: Float, size: Float, color: ColorEditNode) {
        self.xPos = xPos;
        self.yPos = yPos;
        self.size = size;
        self.color = color;
    }
}


