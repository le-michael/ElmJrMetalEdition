//
//  EVMenuView.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-02.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

struct StoreSection {
    let name: String
    let nodes: [EINode]
}

var store = [
    StoreSection(name: "numbers", nodes: [
        EIAST.List([
            EIAST.FunctionApplication(
                function: EIAST.Function(parameter: "we", body: EIAST.Integer(1)),
                argument: EIAST.Integer(1)),
            EIAST.ConstructorInstance(constructorName: "123123", parameters: [EIAST.Integer(1)]),
            EIAST.ConstructorInstance(constructorName: "123123werwerwer", parameters: [EIAST.Integer(1), EIAST.Integer(1), EIAST.Integer(1)]),
            EIAST.ConstructorInstance(constructorName: "123123werwerwerwer", parameters: [EIAST.Integer(1)]),
            EIAST.ConstructorInstance(constructorName: "123123werwerhjgkjhgkjhgkjhgkjhgkjhgkjhgkjhgkjhgkjhgwerwerwerewr", parameters: [EIAST.Integer(1)]),
        ]),
        EIAST.Integer(1),
        EIAST.BinaryOp(
            EIAST.Integer(1),
            EIAST.NoValue(),
            .add
        ),
        EIAST.NoValue(),
    ]),
    StoreSection(name: "conditions", nodes: [
        EIAST.Boolean(true),
        EIAST.Boolean(false),
    ]),
]

class EVMenuView: UIView {
    
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = EVTheme.Colors.background
                        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 200, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 500, height: 140)

        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView?.register(EVProjectionalNodeSource.self, forCellWithReuseIdentifier: "ProjectionalNodeSource")
        collectionView?.register(
            EVSectionHeaderView.self,
            forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        );

        collectionView?.dataSource = self
        collectionView?.delegate = self
        addSubview(collectionView)
        collectionView.backgroundColor = .clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EVMenuView: UICollectionViewDelegate {
    
}

extension EVMenuView: UICollectionViewDataSource {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return store.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store[section].nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectionalNodeSource", for: indexPath) as! EVProjectionalNodeSource
        let node = store[indexPath.section].nodes[indexPath.row] as! EVProjectionalNode
        cell.addSubview(node.getUIView(isStore: true))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let  cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! EVSectionHeaderView
        cell.label.text = store[indexPath.section].name
        return cell
    }
}
