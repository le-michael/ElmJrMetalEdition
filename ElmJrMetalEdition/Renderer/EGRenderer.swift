//
//  EGRenderer.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

enum EGPipelineStates {
    case PrimitivePipelineState
    case BezierPipelineState
}

class EGRenderer: NSObject {
    let view: MTKView
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    let scene: EGScene
    
    var depthStencilState: MTLDepthStencilState?
    var pipelineStates: EGPipelineState
    
    init(view: MTKView, scene: EGScene) {
        self.view = view
        view.depthStencilPixelFormat = .depth32Float
        
        self.device = view.device!
        commandQueue = device.makeCommandQueue()!
        
        self.scene = scene
        scene.fps = Float(view.preferredFramesPerSecond)
        scene.createBuffers(device: device)
        
        view.clearColor = scene.viewClearColor
        
        pipelineStates = EGPipelineState(device: device, view: view)
        
        super.init()
        buildDepthStencilState()
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
              let depthStencilState = depthStencilState,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEnconder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEnconder?.setDepthStencilState(depthStencilState)
        
        scene.draw(commandEncoder: commandEnconder!, pipelineStates: pipelineStates)
        
        commandEnconder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
