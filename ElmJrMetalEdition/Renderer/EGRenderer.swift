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
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let view: MTKView
    let scene: EGScene
    
    var depthStencilState: MTLDepthStencilState?
    var pipelineStates: [EGPipelineStates: MTLRenderPipelineState] = [:]
    
    init(device: MTLDevice, view: MTKView, scene: EGScene) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.view = view
        self.scene = scene
        view.depthStencilPixelFormat = .depth32Float
        scene.fps = Float(view.preferredFramesPerSecond)
        scene.createBuffers(device: device)
        super.init()
        buildPipelineStates()
        buildDepthStencilState()
    }
    
    private func buildPipelineStates() {
        guard let library = device.makeDefaultLibrary() else {
            print("buildPipelineStates error: Unable to generate MTLLibrary")
            return
        }

        do {
            let primitivePipelineState = try EGPipelineStateBuilder.createPrimitivePipelineState(
                library: library,
                device: device,
                view: view
            )
            pipelineStates[.PrimitivePipelineState] = primitivePipelineState
            
            let bezierPipelineState = try EGPipelineStateBuilder.createBezierPipelineState(
                library: library,
                device: device,
                view: view
            )
            pipelineStates[.BezierPipelineState] = bezierPipelineState
        } catch let error as NSError {
            print("buildPipelineStates error: \(error.localizedDescription)")
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
