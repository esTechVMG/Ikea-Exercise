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
        CellInfo(name: "balon", backColor: UIColor.blue),
        CellInfo(name: "medusa", backColor: UIColor.yellow),
        CellInfo(name: "mesa", backColor: UIColor.green),
        CellInfo(name: "taza", backColor: UIColor.purple),
        CellInfo(name: "vasija", backColor: UIColor.white)
    ]
    var selectedItem:CellInfo = CellInfo()
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
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: #selector(self.longPress(gestureReconizer:)))
        sceneView.addGestureRecognizer(tap)
        sceneView.addGestureRecognizer(longPress)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let results = self.sceneView.hitTest(gesture.location(in: gesture.view), types: ARHitTestResult.ResultType.featurePoint)
        guard let result:ARHitTestResult = results.first else {return}
        addItem(hitTestResult: result)
    }
    var touchedNode:SCNNode?
    @objc func longPress(gestureReconizer: UILongPressGestureRecognizer) -> Void {
        print("Long Press Detected")
        if gestureReconizer.state == .began{
            let location: CGPoint = gestureReconizer.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                print("You longPressed \(tappedNode?.name ?? "UnknownNode in func longPress()")")
                tappedNode?.runAction(rotation(time: 2))
                touchedNode = tappedNode
            }
        }
        if gestureReconizer.state == .ended{
            guard let longPresedNode = touchedNode else {return}
            longPresedNode.removeAllActions()
        }
    }
    func rotation(time:TimeInterval) -> SCNAction{
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotation)
        return foreverRotation
    }
    
    func addItem(hitTestResult: ARHitTestResult) -> Void {
        print("Tap Detected")
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        let node = selectedItem.node.copy() as! SCNNode
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        
        if selectedItem.name.lowercased() == "mesa"{
            print("Table position workaround")
            node.position = SCNVector3(node.position.x - 0.35 ,node.position.y,node.position.z - 0.35)
        }
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    //CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfObjects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        let cellInfo:CellInfo = listOfObjects[indexPath.row]
        cell.name.text = cellInfo.name.capitalized
        cell.backgroundColor = cellInfo.backColor
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = listOfObjects[indexPath.row]
        showTempInfoInLabel(seconds: 4, message: "\(selectedItem.name.capitalized) Seleccionado")
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    //ARSCNView
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        showTempInfoInLabel(seconds: 4, message: "Plano Detectado")
    }
    
    func createLava(planeAnchor:ARPlaneAnchor) -> SCNNode {
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        lavaNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        lavaNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "lava")
        lavaNode.position = SCNVector3(0,0,0)
        lavaNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true
        return lavaNode
    }
    func showTempInfoInLabel(seconds:Double,message:String) -> Void {
        DispatchQueue.main.async {
            self.planeDetectedLabel.text = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.planeDetectedLabel.text = ""
        }
    }
}

class CellInfo {
    var name:String
    var backColor:UIColor
    var node:SCNNode
    init(name:String, backColor:UIColor) {
        self.name = name
        self.backColor = backColor
        self.node = SCNScene(named: "art.scnassets/\(name).scn")?.rootNode.childNode(withName: name, recursively: false) ?? SCNNode()
    }
    init() {
        name = ""
        backColor = UIColor.black
        node = SCNNode()
    }
}

extension Int{
    var degreesToRadians:Double{return Double(self) * .pi/180}
}
