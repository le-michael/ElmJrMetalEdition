//
//  Bezier.metal
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#include <metal_stdlib>
#include "Types.h"

using namespace metal;

vertex VertexOut bezier_vertex_shader(const BezierVertexIn vertexIn [[ stage_in ]],
                               constant BezierVertexUniforms &vertexUniforms [[ buffer(1) ]]) {
    VertexOut vertexOut;
    
    float cx = 3.0 * (vertexUniforms.p1.x - vertexUniforms.p0.x);
    float bx = 3.0 * (vertexUniforms.p2.x - vertexUniforms.p1.x) - cx;
    float ax = vertexUniforms.p3.x - vertexUniforms.p0.x - cx - bx;
    
    float cy = 3.0 * (vertexUniforms.p1.y - vertexUniforms.p0.y);
    float by = 3.0 * (vertexUniforms.p2.y - vertexUniforms.p1.y) - cy;
    float ay = vertexUniforms.p3.y - vertexUniforms.p0.y - cy - by;
    
    float tSquared = vertexIn.time * vertexIn.time;
    float tCubed = tSquared * vertexIn.time;
    
    float x = (ax * tCubed) + (bx * tSquared) + (cx * vertexIn.time) + vertexUniforms.p0.x;
    float y = (ay * tCubed) + (by * tSquared) + (cy * vertexIn.time) + vertexUniforms.p0.y;
    
    vertexOut.position = vertexIn.position;
    vertexOut.position.x = x;
    vertexOut.position.y  = y;
    vertexOut.position = vertexUniforms.modelViewMatrix * vertexOut.position;
    vertexOut.color = vertexUniforms.color;
    
    return vertexOut;
}
