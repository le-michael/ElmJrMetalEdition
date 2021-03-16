//
//  ModelPreview.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-03-15.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import MetalKit
import UIKit

class EVModelPreview: UIView {
    let mtkView = MTKView()
    var renderer: EGRenderer!

    var previousScale: CGFloat = 1

    private func previewScene(modelName: String) -> EGScene {
        let scene = EGScene()
        let camera = EGArcballCamera(distance: 3, target: [0, -1, 0])
        scene.camera = camera
        scene.viewClearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        scene.lights.append(
            EGDirectionaLight(
                color: (EGConstant(0.6), EGConstant(0.6), EGConstant(0.6)),
                position: (EGConstant(1), EGConstant(2), EGConstant(2)),
                intensity: EGConstant(0),
                specularColor: (EGConstant(0.1), EGConstant(0.1), EGConstant(0.1))
            )
        )
        scene.lights.append(
            EGAmbientLight(
                color: (EGConstant(1), EGConstant(1), EGConstant(1)),
                intensity: EGConstant(0.5)
            )
        )
        
        let model = EGModel(modelName: modelName)
        model.transform.rotate.set(x: EGConstant(0), y: EGTime(), z: EGConstant(0))
        scene.add(model)
        
        return scene
    }
    
    func changePreviewModel(modelName:String) {
        if modelName == "" {
            self.isHidden = true
            return
        }
        self.isHidden = false
        previousScale = 1;
        let scene = previewScene(modelName: modelName)
        renderer.use(scene: scene)
        guard let s = renderer.scene else { return }
        s.setDrawableSize(size: mtkView.frame.size)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        EVEditor.shared.subscribe(delegate: self)
        self.isHidden = true
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubview(mtkView)
        mtkView.backgroundColor = .clear
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mtkView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        mtkView.device = MTLCreateSystemDefaultDevice()
        

        renderer = EGRenderer(view: mtkView)
        renderer.use(scene: previewScene(modelName: "alien.obj"))//"hangar_largeA.obj"))
        mtkView.delegate = renderer

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        mtkView.addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        mtkView.addGestureRecognizer(pinch)
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let scene = renderer.scene else { return }

        let translation = gesture.translation(in: gesture.view)
        let delta = simd_float2(Float(translation.x), Float(-translation.y))

        scene.camera.rotate(delta: delta)

        gesture.setTranslation(.zero, in: gesture.view)
    }

    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let scene = renderer.scene else { return }

        let delta = Float(gesture.scale - previousScale)
        scene.camera.zoom(delta: delta)

        previousScale = gesture.scale
        if gesture.state == .ended {
            previousScale = 1
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EVModelPreview: EVEditorDelegate {
    func didChangeTextEditorWidth(width: CGFloat) {}
    
    func didChangeSourceCode(sourceCode: String) {}
    
    func didOpenProjects() {}
    
    func didLoadProject(project: EVProject) {}
    
    func didUpdateScene(scene: EGScene) {}
    
    func didToggleMode() {}
    
    func didOpenNodeMenu(title: String, options: [EVNodeMenuOption]) {}
    
    func didCloseNodeMenu() {
        changePreviewModel(modelName: "")
    }
    
    func didUpdateModelPreview(modelFileName: String) {
        changePreviewModel(modelName: modelFileName)
    }
    
    
}
