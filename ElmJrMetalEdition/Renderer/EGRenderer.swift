//
//  EGRenderer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class EGRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let view: MTKView
    let scene: EGScene
    
    var pipelineState: MTLRenderPipelineState?
    var depthStencilState: MTLDepthStencilState?
    
    init(device: MTLDevice, view: MTKView, scene: EGScene) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.view = view
        self.scene = scene
        view.depthStencilPixelFormat = .depth32Float
        scene.fps = Float(view.preferredFramesPerSecond)
        super.init()
        buildPipelineState()
        buildDepthStencilState()
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
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<EGVertex>.stride
        
        pipeLineDescriptor.vertexDescriptor = vertexDescriptor
        pipeLineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipeLineDescriptor)
        } catch let error as NSError {
            print("makePipelineState error: \(error.localizedDescription)")
        }
    }
    
    private func buildDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}

extension EGRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.setDrawableSize(size: size)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
              let depthStencilState = depthStencilState,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEnconder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEnconder?.setDepthStencilState(depthStencilState)
        
        scene.draw(commandEncoder: commandEnconder!, pipelineState: pipelineState)
        
        commandEnconder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
