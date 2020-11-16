//
//  Primative.metal
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]]) {
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}
