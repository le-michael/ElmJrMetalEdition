//
//  Primitive3D.metal
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

vertex VertexOut primitive3d_vertex_shader(
    const VertexIn vertexIn [[ stage_in ]],
    constant PrimitiveVertexUniforms &vertexUniforms [[ buffer(BufferVertexUniforms) ]]
) {
    VertexOut vertexOut {
        .position = vertexUniforms.projectionMatrix * vertexUniforms.viewMatrix * vertexUniforms.modelMatrix * vertexIn.position,
        .worldPosition = (vertexUniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal =  vertexUniforms.normalMatrix * vertexIn.normal
    };
    
    return vertexOut;
}

fragment float4 primitive3d_fragment_shader(
    VertexOut vertexIn [[ stage_in ]],
    constant PrimitiveFragmentUniforms &fragmentUniforms [[ buffer(BufferFragmentUniforms) ]],
    constant Light *lights [[ buffer(BufferLights) ]]
) {
    if (fragmentUniforms.surfaceType == Lit) {
        // Directional
        float3 baseColor = fragmentUniforms.baseColor.rgb;
        float3 diffuseColor = 0;
        
        // Specular
        float3 specularColor = 0;
        float materialShine = fragmentUniforms.materialShine;
        float3 materialSpecularColor = fragmentUniforms.materialSpecularColor;
        
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
                    specularColor += light.specularColor * materialSpecularColor * specularIntensity;
                }
            } else if (light.type == Ambient) {
                ambientColor +=  baseColor * light.color * light.intensity;
            } else if (light.type == Point) {
                float d = distance(light.position, vertexIn.worldPosition);
                float3 lightDirection = normalize(vertexIn.worldPosition - light.position);
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            } else if (light.type == Spotlight) {
                float d = distance(light.position, vertexIn.worldPosition);
                float3 lightDirection = normalize(vertexIn.worldPosition - light.position);
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, coneDirection);
                if (spotResult > cos(light.coneAngle)) {
                  float attenuation = 1.0 / (light.attenuation.x +
                      light.attenuation.y * d + light.attenuation.z * d * d);
                  attenuation *= pow(spotResult, light.coneAttenuation);
                  float diffuseIntensity =
                           saturate(dot(-lightDirection, normalDirection));
                  float3 color = light.color * baseColor * diffuseIntensity;
                  color *= attenuation;
                  diffuseColor += color;
                }
            }
        }
        float3 color = diffuseColor + ambientColor + specularColor;
        return float4(color, 1);
    }
    
    return float4(vertexIn.color);
}
