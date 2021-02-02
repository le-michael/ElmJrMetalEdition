//
//  ViewController.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2020-09-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import UIKit

class EVProjectMenuViewController: UIViewController {
    
    var projectsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EVProjectManager.shared.subscribe(delegate: self)
        view.backgroundColor = EVTheme.Colors.background
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 200, height: 60)
        layout.footerReferenceSize = CGSize(width: 200, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 280, height: 60)

        
        projectsCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        projectsCollectionView?.register(EVProjectsMenuCell.self, forCellWithReuseIdentifier: "ProjectsMenuCell")
        projectsCollectionView?.register(EVButtonCell.self, forCellWithReuseIdentifier: "ButtonCell")
        projectsCollectionView?.register(
            EVSectionHeaderView.self,
            forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        );
        projectsCollectionView?.register(
            EVButtonCell.self,
            forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "FooterButtonCell"
        );

        projectsCollectionView?.dataSource = self
        projectsCollectionView?.delegate = self
        view.addSubview(projectsCollectionView)
        projectsCollectionView.backgroundColor = .clear
        
        projectsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        projectsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        projectsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        projectsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        projectsCollectionView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func metalWorkspaceButtonClicked(){
        let metalWorkspaceController = MetalWorkspaceController()
        metalWorkspaceController.modalPresentationStyle = .fullScreen
        self.present(metalWorkspaceController, animated: true, completion: nil)
    }
    
    func metalWorkspace2ButtonClicked(){
        let metalWorkspace2Controller = MetalWorkspace2Controller()
        metalWorkspace2Controller.modalPresentationStyle = .fullScreen
        self.present(metalWorkspace2Controller, animated: true, completion: nil)
    }
    
    func createNewProject(){
        let alert = UIAlertController(title: "Choose a name for your project", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "New Project " + String(EVProjectManager.shared.projects.count + 1)
        }
        alert.addAction(UIAlertAction(title: "Create Project", style: .default, handler: { [weak alert] (_) in
            guard let projectName = alert?.textFields![0].text else { return }
            EVProjectManager.shared.createProject(projectName: projectName)
            EVEditor.shared.loadProject(projectTitle: projectName)
            EVEditor.shared.toggleProjectMenu()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
}

extension EVProjectMenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:200, height:200)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if section == 1 {
            return CGSize(width:200, height:0)
        }
        return CGSize(width:200, height:200)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectsMenuCell", for: indexPath) as! EVProjectsMenuCell
            cell.setProject(project: EVProjectManager.shared.projects[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as! EVButtonCell
            if indexPath.row == 0 {
                cell.button.setTitle("Metal Workspace 1", for: .normal)
                cell.callback = metalWorkspaceButtonClicked
            } else {
                cell.button.setTitle("Metal Workspace 2", for: .normal)
                cell.callback = metalWorkspace2ButtonClicked
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let  cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! EVSectionHeaderView
            cell.label.text = indexPath.section == 0 ? "Projects" : "Demos"
            return cell
        }
        
        let  cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterButtonCell", for: indexPath) as! EVButtonCell
        if indexPath.section == 0 {
            cell.button.setTitle("+ Create new project", for: .normal)
            cell.button.setTitleColor(EVTheme.Colors.secondaryHighlighted, for: .normal)
            cell.callback = createNewProject
        }

        return cell
                
    }
}

extension EVProjectMenuViewController: UICollectionViewDataSource {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section==0) {
            return EVProjectManager.shared.projects.count
        }
        return 2
    }
}

extension EVProjectMenuViewController: EVProjectManagerDelegate {
    func didSaveSuccessfully() { }
    
    func didUpdateProjects() {
        projectsCollectionView.reloadData()
    }
    
}

