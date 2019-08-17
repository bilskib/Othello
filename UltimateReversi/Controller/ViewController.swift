//
//  ViewController.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    private var scene: GameLogicUI!
    private var gameLogic: GameLogic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let skView = self.view as! SKView
        let size = CGSize(width: 640, height: 760)
        scene = GameLogicUI(size: size)
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
        gameLogic = GameLogic(scene: scene)
        gameLogic.setInitialBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scene)
            if let node: SKSpriteNode = scene.atPoint(location) as? SKSpriteNode {
                if let num = Int(node.name!) {
                    let row = num / 10
                    let column = num % 10
                    gameLogic.cellPressed(row: row,column)
                }
            } else {
                gameLogic.cellPressed(row: -1,-1)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

