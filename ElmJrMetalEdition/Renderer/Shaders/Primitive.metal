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

struct VertexIn {
    vector_float4 position [[ attribute(0) ]];
    vector_float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    vector_float4 position [[ position ]];
    vector_float4 color;
    vector_float3 worldPosition;
    vector_float3 worldNormal;
};

vertex VertexOut primitive_vertex_shader(
    const VertexIn vertexIn [[ stage_in ]],
    constant PrimitiveVertexUniforms &vertexUniforms [[ buffer(1) ]]
) {
    VertexOut vertexOut {
        .position = vertexUniforms.projectionMatrix * vertexUniforms.viewMatrix * vertexUniforms.modelMatrix * vertexIn.position,
        .color = vertexUniforms.color,
        .worldPosition = (vertexUniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal =  vertexUniforms.normalMatrix * vertexIn.normal
    };
    
    return vertexOut;
}

fragment float4 primitive_fragment_shader(
    VertexOut vertexIn [[ stage_in ]],
    constant PrimitiveFragmentUniforms &fragmentUniforms [[ buffer(2) ]],
    constant Light *lights [[buffer(3)]]
) {
    if (fragmentUniforms.surfaceType == Lit) {
        // Directional
        float3 baseColor = vertexIn.color.xyz;
        float3 diffuseColor = 0;
        
        // Specular
        float3 specularColor = 0;
        float materialShine = 32;
        float3 materialSpecularColor = float3(0.6, 0.6, 0.6);
        
        // Ambient
        float3 ambientColor = 0;
        
        float3 normalDirection = normalize(vertexIn.worldNormal);
        for (uint i = 0; i < fragmentUniforms.lightCount; i++) {            
            Light light = lights[i];
            if (light.type == Directional) {
                float3 lightDirection = normalize(-light.position);
                float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
                diffuseColor += light.color * baseColor * diffuseIntensity;
                if (diffuseIntensity > 0) {
                    float3 reflection = reflect(lightDirection, normalDirection);
                    float3 cameraDirection = normalize(vertexIn.worldPosition - fragmentUniforms.cameraPosition);
                    float3 specularIntensity = pow(saturate(-dot(reflection, cameraDirection)), materialShine);
                    specularColor += float3(0.6, 0.6, 0.6) * materialSpecularColor * specularIntensity;
                }
            } else if (light.type == Ambient) {
                ambientColor += light.color * light.intensity;
            }
        }
        float3 color = diffuseColor + ambientColor + specularColor;
        return float4(color, 1);
    }
    
    return float4(vertexIn.color);
}
