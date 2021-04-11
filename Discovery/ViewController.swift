//
//  ViewController.swift
//  Discovery
//
//  Created by Pranav Kannan Nampoothiripad on 4/9/21.
//

import UIKit
import ARKit


class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var addTo : [String] = []
    var audioPlayer = AVAudioPlayer();
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    func setUp(){
        let session = sceneView.session;
        session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        //configuration.frameSemantics.insert(.personSegmentationWithDepth)
        //configuration.planeDetection = [.horizontal,.vertical]
        session.run(configuration)
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        alphabetRun()
    }
    func alphabetRun(){
        let shuffledLetters = letters.shuffled()
        print(letters)
        print(shuffledLetters)
        for i in 0..<letters.count{
            print(shuffledLetters[i])
            createCube(letter: shuffledLetters[i])
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(checkTouch))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    func createCube(letter: String) {
        let box = SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box;
        let number1 = Double.random(in: -2...2)
        let number2 = Double.random(in: -2...2)
        print("numbers: \(number1) and \(number2)")
        boxNode.position = SCNVector3(number1,0,number2);
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: letter)
        boxNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        boxNode.name = letter
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    @objc func checkTouch(sender: UITapGestureRecognizer){
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location)
        if let node = hitTest.first?.node{
            if(addTo.count<=letters.count){
                addTo.append(node.name!)
                if(addTo[addTo.count-1]==letters[addTo.count-1]){
                    createExplosion(position: node.position)
                    node.removeFromParentNode()
                    playSound(sound: "CorrectLetterSound")
                }else{
                    addTo.remove(at: addTo.count-1)
                    print("Not in order")
                    playSound(sound: "WrongLetterSound")
                }
            }
        }
    }
    func createExplosion(position : SCNVector3){
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 200;
        particleSystem.birthDirection = .random
        particleSystem.speedFactor = 1.2
        particleSystem.particleSize = 0.2
        particleSystem.particleVelocity = 3
        particleSystem.emissionDuration = 1
        particleSystem.particleColor = .orange
        particleSystem.loops = false
        let fireNode = SCNNode()
        fireNode.addParticleSystem(particleSystem)
        fireNode.position = position;
        self.sceneView.scene.rootNode.addChildNode(fireNode)
        playSound(sound: "CorrectLetterSound")
    }

    func playSound(sound:String) {
        let audioFilePath = Bundle.main.path(forResource: sound, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl, fileTypeHint: nil)
            audioPlayer.play()
            }
            catch{
                
            }
            
        } else {
            print("audio file is not found")
        }

    }

}
