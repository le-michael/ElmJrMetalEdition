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
};

struct VertexOut {
    vector_float4 position [[ position ]];
    vector_float4 color;
};

vertex VertexOut primitive_vertex_shader(
    const VertexIn vertexIn [[ stage_in ]],
    constant PrimitiveVertexUniforms &vertexUniforms [[ buffer(BufferVertexUniforms) ]]
) {
    VertexOut vertexOut {
        .position = vertexUniforms.projectionMatrix
            * vertexUniforms.viewMatrix
            * vertexUniforms.modelMatrix
            * vertexIn.position,
    };
    
    return vertexOut;
}

fragment float4 primitive_fragment_shader(
    VertexOut vertexIn [[ stage_in ]],
    constant PrimitiveFragmentUniforms &fragmentUniforms [[buffer(BufferFragmentUniforms)]]
) {
    return float4(fragmentUniforms.baseColor);
}
