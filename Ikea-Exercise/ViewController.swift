//
//  ViewController.swift
//  Ikea-Exercise
//
//  Created by A4-iMAC01 on 03/03/2021.
//

import UIKit
import ARKit
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, ARSCNViewDelegate {
    //Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var planeDetectedLabel: UILabel!
    //Static configs
    let scnConfig = ARWorldTrackingConfiguration()
    var listOfObjects = [
        CellInfo(name: "Hello", backColor: UIColor.red, node: SCNNode()),
        CellInfo(name: "World", backColor: UIColor.blue, node: SCNNode()),
        CellInfo(name: "This", backColor: UIColor.yellow, node: SCNNode()),
        CellInfo(name: "is", backColor: UIColor.green, node: SCNNode()),
        CellInfo(name: "a", backColor: UIColor.purple, node: SCNNode()),
        CellInfo(name: "collection", backColor: UIColor.white, node: SCNNode()),
        CellInfo(name: "view", backColor: UIColor.orange, node: SCNNode())
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        collectionView.delegate = self
        collectionView.dataSource = self
        sceneView.delegate = self
        sceneView.debugOptions = [
            .showWorldOrigin,
            .showFeaturePoints
        ]
        scnConfig.planeDetection = .horizontal
        sceneView.session.run(scnConfig)
        
    }
    //CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfObjects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        let cellInfo:CellInfo = listOfObjects[indexPath.row]
        cell.name.text = cellInfo.name
        cell.backgroundColor = cellInfo.backColor
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Called SCNode Instantiation")
        //SCN Node instantiation
        let node = listOfObjects[indexPath.row].node.copy() as! SCNNode
        
        node.position = SCNVector3(x: 0, y: 0, z: 0)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    //ARSCNView
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
}

class CellInfo {
    var name:String
    var backColor:UIColor
    var node:SCNNode
    init(name:String, backColor:UIColor, node:SCNNode) {
        self.name = name
        self.backColor = backColor
        self.node = node
    }
}
