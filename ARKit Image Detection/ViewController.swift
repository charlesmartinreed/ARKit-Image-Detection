//
//  ViewController.swift
//  ARKit Image Detection
//
//  Created by Charles Martin Reed on 1/9/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //replacing ARWorldImageTrackingConfiguration
        //let configuration = ARWorldTrackingConfiguration()
        let configuration = ARImageTrackingConfiguration()
        
        //images will be placed in the Assets folder, created by right clicking and choosing "New AR Resource Group"
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }
        
        //now, our config will look for images as specified in our tracked images bundle
        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1 //right now, just testing for the single card

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        //always called when a new anchor is added to the scene, such as when we find our image in the AR world
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
            
            let planeNode = SCNNode(geometry: plane)
            
            //rotate plane node to match that of the image
            planeNode.eulerAngles.x = -.pi / 2
            
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = SCNVector3Zero
            shipNode.position.z = 0.15 //moving the node a little closr to the user
            
            planeNode.addChildNode(shipNode)
            
            node.addChildNode(planeNode)
        }
        
        return node
    }
}
