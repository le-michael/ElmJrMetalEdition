//	
//  Renderer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let view: MTKView
    let scene: Scene
    
    var pipelineState: MTLRenderPipelineState?
    
    init(device: MTLDevice, view: MTKView, scene: Scene) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.view = view
        self.scene = scene
        super.init()
        buildPipelineState()
    }
    
    
    private func buildPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        let pipeLineDescriptor = MTLRenderPipelineDescriptor()
        pipeLineDescriptor.vertexFunction = vertexFunction
        pipeLineDescriptor.fragmentFunction = fragmentFunction
        pipeLineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<simd_float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipeLineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipeLineDescriptor)
        } catch let error as NSError {
            print("makePipelineState error: \(error.localizedDescription)")
        }
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw (in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEnconder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        scene.draw(commandEncoder: commandEnconder!, pipelineState: pipelineState)
        
        commandEnconder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
