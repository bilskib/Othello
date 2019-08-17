//
//  GameLogicUI.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import SpriteKit

final class GameLogicUI: SKScene {
    
    private var atlas: SKTextureAtlas!
    private var gearSprite: SKSpriteNode!   // AI activity indicator
    
    override func didMove(to view: SKView) {
        atlas = createAtlas()
        gearSprite = createAIIndicator()
        displayEmptyBoard()
    }
    
    func displayChip(color: CellType, row: Int, column: Int) {
        if let cell = childNode(withName: "\(row)\(column)") as! SKSpriteNode? {
        let chipSize = CGSize(width: cell.size.width * 0.85, height: cell.size.height * 0.85)
        let texture = color == .White ? atlas.textureNamed(Constants.ChipImages.whiteChip) : atlas.textureNamed(Constants.ChipImages.blackChip)
        let chip = SKSpriteNode(texture: texture, size: chipSize)
        chip.name = cell.name
        chip.zPosition = 1
        chip.isUserInteractionEnabled = true
            cell.addChild(chip)}
    }
    
    func updateChip(color: CellType, _ row: Int, _ column: Int) {
        if let cell = childNode(withName: "\(row)\(column)") as! SKSpriteNode? {
            let chip = cell.children[0] as! SKSpriteNode
            let savedWidth = chip.frame.width
            let resizeToLine = SKAction.resize(toWidth: 4, duration: 0.25)
            let texture = color == .White ?
                atlas.textureNamed(Constants.ChipImages.whiteChip) :
                atlas.textureNamed(Constants.ChipImages.blackChip)
            let changeColor = SKAction.setTexture(texture)
            let restoreWidth = SKAction.resize(toWidth: savedWidth, duration: 0.25)
            let sequence = SKAction.sequence([resizeToLine, changeColor, restoreWidth])
            chip.run(sequence, completion: {chip.texture = texture}) }
    }
    
    private func drawCountsLabel() {
        let topSquare = self.childNode(withName: "74") as! SKSpriteNode
        let fontSize = topSquare.frame.height * 0.6
        let y = topSquare.frame.maxY + (fontSize/2) - 1
        let countsLabel = SKLabelNode(fontNamed: Constants.Fonts.countsFont)
        countsLabel.text = "White: 0  Black: 0"
        countsLabel.fontSize = fontSize
        countsLabel.position = CGPoint(x: self.frame.midX, y: y)
        countsLabel.fontColor = SKColor.white
        countsLabel.name = Constants.countsLabelSpriteName
        countsLabel.zPosition = 1
        self.addChild(countsLabel)
    }
    
    func displayAlert(text: String) {
        let alert = SKLabelNode(fontNamed: Constants.Fonts.alertFont)
        let topSquare = self.childNode(withName: "74") as! SKSpriteNode
        let fontSize = topSquare.frame.height * 0.6
        alert.fontSize = fontSize
        let x = self.frame.midX
        let y = self.frame.midY
        alert.position = CGPoint(x: x, y: y)
        alert.text = text
        alert.zPosition = 2
        alert.fontColor = SKColor.red
        alert.name = Constants.alertSpriteName
        alert.isUserInteractionEnabled = true
        self.addChild(alert)
    }
    
    func removeAlert() {
        let alert = self.childNode(withName: Constants.alertSpriteName)
        alert?.removeFromParent()
    }
    
    private func createAtlas() -> SKTextureAtlas {
        let chipImages = ChipImages()
        let dictionary = [
            Constants.ChipImages.whiteChip: chipImages.whiteChipWithLight,
            Constants.ChipImages.blackChip: chipImages.blackChipWithLight,
            Constants.cellImage: chipImages.cellImage ]
        return SKTextureAtlas(dictionary: dictionary as [String : Any])
    }

    func updateCountsLabel(white: Int, black: Int) {
        if let label = childNode(withName: Constants.countsLabelSpriteName)
            as! SKLabelNode? {
            label.text = "White: \(white)  Black: \(black)" }
    }
    
    private func createAIIndicator() -> SKSpriteNode {
        let gear = SKSpriteNode(imageNamed: Constants.gearImage)
        let size = self.size.width/10
        gear.size = CGSize(width: size, height: size)
        return gear
    }
    
    func showAIIndicator(check: Bool) {
        if check == true {
            let y = self.frame.maxY-(gearSprite.size.height/2)-1
            gearSprite.position = CGPoint(x: self.frame.midX, y: y)
            gearSprite.zPosition = 2
            let action = SKAction.rotate(byAngle: CGFloat(-Double.pi/2), duration: 2)
            gearSprite.run(SKAction.repeat(action, count: 5))
            self.addChild(gearSprite)
        } else {
            gearSprite.removeFromParent()
        }
    }
    
    private func displayEmptyBoard() {
        // Board parameters
        let size = self.size.width
        let boxSideLength = (size)/8
        let squareSize = CGSize(width: boxSideLength, height: boxSideLength)
        // draw board
        let yOffset: CGFloat = (boxSideLength/2)
        for row in 0..<8 {
            let xOffset: CGFloat = (boxSideLength/2)
            for col in 0..<8 {
                let square = SKSpriteNode(
                    texture: atlas.textureNamed(Constants.cellImage),
                    size: squareSize)
                square.position = CGPoint(x: CGFloat(col) * squareSize.width + xOffset, y: CGFloat(row) * squareSize.height + yOffset)
                square.name = "\(row)\(col)"
                square.isUserInteractionEnabled = true
                self.addChild(square)
            }
        }
        drawCountsLabel()
    }
    
    func clearGameView() {
        for row in 0..<8 {
            for col in 0..<8 {
                if let cell = childNode(withName: "\(row)\(col)") as! SKSpriteNode? {
                    if cell.children.isEmpty {
                        continue
                    }
                    cell.removeAllChildren()
                }
            }
        }
    }
}
