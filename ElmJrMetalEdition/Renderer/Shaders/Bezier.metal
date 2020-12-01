//
//  Bezier.metal
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-30.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct BezierModelConstants {
    float4x4 modelViewMatrix;
    float4 color;
    float2 p0;
    float2 p1;
    float2 p2;
    float2 p3;
};

struct BezierVertexIn {
    float4 position [[ attribute(0) ]];
    float time [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut bezier_vertex_shader(const BezierVertexIn vertexIn [[ stage_in ]],
                               constant BezierModelConstants &modelConstants [[ buffer(1) ]]) {
    VertexOut vertexOut;
    
    float cx = 3.0 * (modelConstants.p1.x - modelConstants.p0.x);
    float bx = 3.0 * (modelConstants.p2.x - modelConstants.p1.x) - cx;
    float ax = modelConstants.p3.x - modelConstants.p0.x - cx - bx;
    
    float cy = 3.0 * (modelConstants.p1.y - modelConstants.p0.y);
    float by = 3.0 * (modelConstants.p2.y - modelConstants.p1.y) - cy;
    float ay = modelConstants.p3.y - modelConstants.p0.y - cy - by;
    
    float tSquared = vertexIn.time * vertexIn.time;
    float tCubed = tSquared * vertexIn.time;
    
    float x = (ax * tCubed) + (bx * tSquared) + (cx * vertexIn.time) + modelConstants.p0.x;
    float y = (ay * tCubed) + (by * tSquared) + (cy * vertexIn.time) + modelConstants.p0.y;
    
    vertexOut.position = vertexIn.position;
    vertexOut.position.x = x;
    vertexOut.position.y  = y;
    vertexOut.position = modelConstants.modelViewMatrix * vertexOut.position;
    vertexOut.color = modelConstants.color;
    
    return vertexOut;
}
