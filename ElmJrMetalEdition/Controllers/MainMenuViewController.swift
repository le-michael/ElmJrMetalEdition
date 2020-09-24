//
//  ViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    let nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .systemBackground
        setupNextButton()
    }
    
    func setupNextButton(){
        view.addSubview(nextButton)
        nextButton.backgroundColor = .blue
        nextButton.setTitle("Go To Editor", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonClicked(_ :)), for: .touchUpInside)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false;
        nextButton.heightAnchor.constraint(equalToConstant: 64).isActive = true;
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true;
        nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true;
        nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true;
    }
    
    @objc func nextButtonClicked(_: UIButton!){
        let editorViewController = EditorViewController()
        editorViewController.modalPresentationStyle = .fullScreen
        self.present(editorViewController, animated: true, completion: nil)
    }

}

