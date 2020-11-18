//
//  EditorViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit
import MetalKit

class EditorViewController : UIViewController {

    var addButton = UIButton();
    
    var editorView = UIStackView();
    
    var outputView = UIView();
    
    var mtkView = MTKView()
    
    var device: MTLDevice!
    var renderer: MTKViewDelegate!
    
    var editNodes : [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        setupEditorView()
        setupOutputView()
        
    }
    
    func setupEditorView() {
        
        view.addSubview(editorView)
        editorView.translatesAutoresizingMaskIntoConstraints = false
        editorView.axis = .vertical;
        editorView.spacing = 16;
        editorView.distribution = .fillEqually;
        editorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        editorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        editorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        editorView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5).isActive = true

        for (index, triangle) in mockData.enumerated() {
            setupTriangleEditNode(triangle: triangle, index:index);
        }
                
    }
    
    func setupTriangleEditNode(triangle: TriangleEditNode, index: Int){
        let triangleEditNode = UILabel()
        triangleEditNode.isUserInteractionEnabled = true
        triangleEditNode.numberOfLines = 5
        triangleEditNode.text = "triangle \(index.description) \n x: \(triangle.xPos.description) \n y: \(triangle.yPos.description) \n size: \(triangle.size.description) \n rotation: \(triangle.rotation)";

        triangleEditNode.translatesAutoresizingMaskIntoConstraints = false;
        triangleEditNode.textColor = .white;
        
        let gesture = TriangleNodeGestureRecognizer(target: self, action: #selector(self.showMenu))
        gesture.triangle = triangle;
        gesture.index = index;
        triangleEditNode.addGestureRecognizer(gesture);
        
        editorView.addArrangedSubview(triangleEditNode);
        editNodes.append(triangleEditNode)
    }
    
    func setupAddButton(){
        editorView.addArrangedSubview(addButton);
        addButton.translatesAutoresizingMaskIntoConstraints = false;
        addButton.backgroundColor = .blue
        addButton.setTitle("Test", for: .normal)
        addButton.addTarget(self, action: #selector(self.showMenu), for: .touchUpInside)
    }
    
    @objc func showMenu(sender: TriangleNodeGestureRecognizer){

        let alert = UIAlertController(title: "Triangle", message: "Edit Triangle", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit X Position", style: .default) { _ in
            self.editXPosition(triangle: sender.triangle!, index: sender.index)
        })

        alert.addAction(UIAlertAction(title: "Edit Y Position", style: .default) { _ in
            self.editYPosition(triangle: sender.triangle!, index: sender.index)

        })
        
        alert.addAction(UIAlertAction(title: "Edit Size", style: .default) { _ in
            self.editSize(triangle: sender.triangle!, index: sender.index)
        })
        
        alert.addAction(UIAlertAction(title: "Edit Rotation", style: .default) { _ in
            self.editRotation(triangle: sender.triangle!, index: sender.index)
        })
        
        if let popoverController = alert.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }

        self.present(alert, animated: true, completion: nil)
 
    }
    
    func editXPosition(triangle: TriangleEditNode, index: Int ) {
        let alert = UIAlertController(title: "Edit X Position", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = String(triangle.xPos)
            textField.keyboardType = .decimalPad
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let str = textField?.text else { return }
            guard let num = Float(str) else { return }
            mockData[index].xPos = num
            self.update()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func editYPosition(triangle: TriangleEditNode, index: Int ) {
        let alert = UIAlertController(title: "Edit Y Position", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = String(triangle.yPos)
            textField.keyboardType = .decimalPad
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let str = textField?.text else { return }
            guard let num = Float(str) else { return }
            mockData[index].yPos = num
            self.update()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func editSize(triangle: TriangleEditNode, index: Int ) {
        let alert = UIAlertController(title: "Edit Size", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = String(triangle.size)
            textField.keyboardType = .decimalPad
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let str = textField?.text else { return }
            guard let num = Float(str) else { return }
            mockData[index].size = num
            self.update()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func editRotation(triangle: TriangleEditNode, index: Int ) {
        let alert = UIAlertController(title: "Edit Rotation", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = String(triangle.rotation)
            textField.keyboardType = .decimalPad
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let str = textField?.text else { return }
            guard let num = Float(str) else { return }
            mockData[index].rotation = num
            self.update()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func setupOutputView(){
        view.addSubview(outputView);
        outputView.backgroundColor = .white;
        outputView.translatesAutoresizingMaskIntoConstraints = false
        outputView.topAnchor.constraint(equalTo: editorView.topAnchor, constant: 0).isActive = true
        outputView.bottomAnchor.constraint(equalTo: editorView.bottomAnchor, constant: 0).isActive = true
        outputView.leadingAnchor.constraint(equalTo: editorView.trailingAnchor, constant: 0).isActive = true
        outputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        setupMetal()
    }
    
    func setupMetal(){
        outputView.addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.topAnchor.constraint(equalTo: outputView.topAnchor, constant: 0).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: outputView.bottomAnchor, constant: 0).isActive = true
        mtkView.leadingAnchor.constraint(equalTo: outputView.leadingAnchor, constant: 0).isActive = true
        mtkView.widthAnchor.constraint(equalTo: outputView.widthAnchor, multiplier: 1).isActive = true
        
        mtkView.device = MTLCreateSystemDefaultDevice()
        device = mtkView.device
        
        let scene = Scene(device: device)
        scene.sceneProps?.viewMatrix = createTranslationMatrix(x: 0, y: 0, z: -3)
        
        let triangles = transpile(data: mockData)
        
        for triangle in triangles {
            print(triangle)
            scene.addChild(node: triangle)
        }
        
        
        mtkView.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        renderer = Renderer(device: device, view: mtkView, scene: scene)
        mtkView.delegate = renderer
    }
    
    func update(){
        for view in editNodes {
            view.removeFromSuperview()
            editorView.removeArrangedSubview(view)
        }
        for (index, triangle) in mockData.enumerated() {
            setupTriangleEditNode(triangle: triangle, index:index);
        }
        mtkView.removeFromSuperview()
        mtkView = MTKView()
        setupMetal()
    }
}

class TriangleNodeGestureRecognizer: UITapGestureRecognizer {
    var index = -1
    var triangle: TriangleEditNode?
}
