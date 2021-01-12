//
//  Primitive.metal
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-16.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

#include <metal_stdlib>
#include "Types.h"

using namespace metal;

vertex VertexOut primitive_vertex_shader(const VertexIn vertexIn [[ stage_in ]],
                               constant PrimitiveVertexUniforms &vertexUniforms [[ buffer(1) ]]) {
    VertexOut vertexOut {
        .position = vertexUniforms.projectionMatrix
            * vertexUniforms.viewMatrix
            * vertexUniforms.modelMatrix
            * vertexIn.position,
        .color = vertexUniforms.color,
        .worldNormal = vertexUniforms.normalMatrix * vertexIn.normal,
        .cameraPosition = vertexUniforms.cameraPosition
    };
    
    return vertexOut;
}

fragment float4 primitive_fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    if (true) {
        // Constants (Temporary)
        float3 lightPositions[] = {{0 ,1, 0}, {1, 0, 0}, {0, 0, 1}, {0 ,-1, 0}, {-1, 0, 0}, {0, 0, -1}};
        float3 lightColor = 1;
        float3 diffuseColor = 0;
        
        float3 normalDirection = normalize(vertexIn.worldNormal);
        
        for (int i = 0; i < 4; i++) {
            
            float3 lightDirection = normalize(-(lightPositions[i]* vertexIn.cameraPosition));
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            diffuseColor += lightColor * vertexIn.color.xyz * diffuseIntensity;
        }
        
        
        return float4(diffuseColor, 1);
    }
    
    return float4(vertexIn.color);
}
