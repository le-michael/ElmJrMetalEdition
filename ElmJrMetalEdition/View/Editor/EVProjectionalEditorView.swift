//
//  EVProjectionalEditorVIew.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-09.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

class EVProjectionalEditorView: UIView {
    
    var rootNodeView: UIView!
    var referenceTransform: CGAffineTransform?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = EVTheme.Colors.background
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView(sender:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
        layer.masksToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pannedView(sender:)))
        addGestureRecognizer(panGesture)
                
        let binaryOp = EIParser.BinaryOp(
            EIParser.Integer(1),
            EIParser.BinaryOp(EIParser.Integer(3), EIParser.FloatingPoint(3), .multiply),
            .add
        )
        rootNodeView = binaryOp.getUIView()
                
        addSubview(rootNodeView)
    }
    
    @objc func pinchedView(sender: UIPinchGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began){
            referenceTransform = rootNodeView.transform
        } else {
            guard let transform = referenceTransform?.scaledBy(x: sender.scale, y: sender.scale) else { return }
            rootNodeView.transform = transform
        }
        
    }
    
    @objc func pannedView(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began){
            referenceTransform = rootNodeView.transform
        } else {
            guard let refTransform = referenceTransform else { return }
            let transform = refTransform.translatedBy(
                x: sender.translation(in: self).x / refTransform.a,
                y: sender.translation(in: self).y / refTransform.a
            )
            rootNodeView.transform = transform
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
