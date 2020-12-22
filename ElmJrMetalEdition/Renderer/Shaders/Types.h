//
//  Types.h
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-12-13.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#ifndef Types_h
#define Types_h

#include <metal_stdlib>

using namespace metal;

struct PrimitiveVertexUniforms {
    float4x4 modelViewMatrix;
    float4 color;
};

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct BezierVertexUniforms {
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

#endif /* Types_h */
