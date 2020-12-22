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
    VertexOut vertexOut;
    vertexOut.position = vertexUniforms.modelViewMatrix * vertexIn.position;
    vertexOut.color = vertexUniforms.color;
    
    return vertexOut;
}

fragment half4 primitive_fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}
