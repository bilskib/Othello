//
//  MenuScene.swift
//  Othello
//
//  Created by Bartosz on 10/09/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var gameTitleLabelNode: SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    var changeLevelButtonNode: SKSpriteNode!
    var changePlayerButtonNode: SKSpriteNode!
    var playerColorLabelNode: SKLabelNode!
    var playerLevelLabelNode: SKLabelNode!
    var magicParticle: SKEmitterNode!
    
    
    override func didMove(to view: SKView) {
        gameTitleLabelNode = (self.childNode(withName: "gameTitleLabel") as! SKLabelNode)
        newGameButtonNode = (self.childNode(withName: "newGameButton") as! SKSpriteNode)
        changeLevelButtonNode = (self.childNode(withName: "changeLevelButton") as! SKSpriteNode)
        changePlayerButtonNode = (self.childNode(withName: "changePlayerButton") as! SKSpriteNode)
        playerColorLabelNode = (self.childNode(withName: "playerColorLabel") as! SKLabelNode)
        playerLevelLabelNode = (self.childNode(withName: "playerLevelLabel") as! SKLabelNode)
        
        magicParticle = SKEmitterNode(fileNamed: "MagicParticle.sks")
        magicParticle.advanceSimulationTime(2.0)
        magicParticle.position = CGPoint.zero
        magicParticle.zPosition = -1
        addChild(magicParticle)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "white") {
            playerColorLabelNode.text = "White"
        } else {
            playerColorLabelNode.text = "Black"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                newGameButtonNode.texture = SKTexture(imageNamed: "newgame_selected")
                let transition = SKTransition.crossFade(withDuration: 0.5)
                let gameScene = GameScene(size: (self.view?.bounds.size)!)
                //let gameLogic = GameLogic(scene: gameScene)
                self.view?.presentScene(gameScene, transition: transition)
               //loadGame()
                
            } else if nodesArray.first?.name == "changeLevelButton" {
                changeLevelButtonNode.texture = SKTexture(imageNamed: "difficulty_selected")
                changeDifficulty()
            } else if nodesArray.first?.name == "changePlayerButton" {
                changePlayerButtonNode.texture = SKTexture(imageNamed: "player_selected")
                changePlayer()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        newGameButtonNode.texture = SKTexture(imageNamed: "newgame")
        changeLevelButtonNode.texture = SKTexture(imageNamed: "difficulty")
        changePlayerButtonNode.texture = SKTexture(imageNamed: "player")
    }
    
    
    func changePlayer (){
        // when a player restarts a game
        let userDefaults = UserDefaults.standard
        if playerColorLabelNode.text == "Black" {
            playerColorLabelNode.text = "White"
            userDefaults.set(true, forKey: "white")
        } else {
            playerColorLabelNode.text = "Black"
            userDefaults.set(false, forKey: "white")
        }
        userDefaults.synchronize()
    }
    
    func changeDifficulty (){
        if playerLevelLabelNode.text == "Easy" {
            playerLevelLabelNode.text = "Medium"
        } else if playerLevelLabelNode.text == "Medium" {
            playerLevelLabelNode.text = "Hard"
        } else if playerLevelLabelNode.text == "Hard" {
            playerLevelLabelNode.text = "Easy"
        }
    }
    
}
