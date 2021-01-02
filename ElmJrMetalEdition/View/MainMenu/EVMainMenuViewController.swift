//
//  ViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class EVMainMenuViewController: UIViewController {
    
    let nextButton = UIButton()
    let metalWorkspaceButton = UIButton()
    let metalWorkspace2Button = UIButton()
    
    let buttonStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .orange
        setupButtons()
    }
    
    func setupButtons(){
        view.addSubview(buttonStack)
        buttonStack.alignment = .bottom;
        buttonStack.axis = .vertical;
        buttonStack.distribution = .fillEqually;
        buttonStack.spacing = 16;

        buttonStack.translatesAutoresizingMaskIntoConstraints = false;
        buttonStack.heightAnchor.constraint(equalToConstant: 300).isActive = true;
        buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true;
        buttonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true;
        buttonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true;
        
        buttonStack.addArrangedSubview(nextButton);
        buttonStack.addArrangedSubview(metalWorkspaceButton);
        buttonStack.addArrangedSubview(metalWorkspace2Button);
        
        nextButton.backgroundColor = .blue
        nextButton.setTitle("Go To Editor", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonClicked(_ :)), for: .touchUpInside)
        
        metalWorkspaceButton.backgroundColor = .blue
        metalWorkspaceButton.setTitle("Go To Metal Workspace 1", for: .normal)
        metalWorkspaceButton.addTarget(self, action: #selector(metalWorkspaceButtonClicked(_ :)), for: .touchUpInside)
        
        metalWorkspace2Button.backgroundColor = .blue
        metalWorkspace2Button.setTitle("Go To Metal Workspace 2", for: .normal)
        metalWorkspace2Button.addTarget(self, action: #selector(metalWorkspace2ButtonClicked(_ :)), for: .touchUpInside)
        
    }
    
    @objc func nextButtonClicked(_: UIButton!){
        let editorViewController = EVEditorViewController()
        editorViewController.modalPresentationStyle = .fullScreen
        self.present(editorViewController, animated: true, completion: nil)
    }
    
    @objc func metalWorkspaceButtonClicked(_: UIButton!){
        let metalWorkspaceController = MetalWorkspaceController()
        metalWorkspaceController.modalPresentationStyle = .fullScreen
        self.present(metalWorkspaceController, animated: true, completion: nil)
    }
    
    @objc func metalWorkspace2ButtonClicked(_: UIButton!){
        let metalWorkspace2Controller = MetalWorkspace2Controller()
        metalWorkspace2Controller.modalPresentationStyle = .fullScreen
        self.present(metalWorkspace2Controller, animated: true, completion: nil)
    }

}

