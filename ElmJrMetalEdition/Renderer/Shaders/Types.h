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
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3x3 normalMatrix;
    float3 cameraPosition;
};

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
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
    float3 worldPosition;
    float3 worldNormal;
    float3 cameraPosition;
};

#endif /* Types_h */
