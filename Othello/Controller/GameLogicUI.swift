//
//  GameLogicUI.swift
//  Othello
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import SpriteKit

final class GameLogicUI: SKScene {
    
    private var atlas: SKTextureAtlas!
    private var actInd = UIActivityIndicatorView()
    
    override func didMove(to view: SKView) {
        atlas = createAtlas()
        displayEmptyBoard()
    }
    
    // Activity Indicator
    func showActivityIndicator(check: Bool) {
        actInd.center = view!.center
        actInd.hidesWhenStopped = true
        actInd.style = .whiteLarge
        view?.addSubview(actInd)
        
        if check == true {
            actInd.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            actInd.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    // Chips
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
    
    // Labels
    private func drawCountsLabel() {
        let countsLabel = SKLabelNode(fontNamed: Constants.appFont)
        countsLabel.fontSize = CGFloat(Constants.appFontSize)
        countsLabel.fontColor = SKColor.white
        countsLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - (self.frame.midX + countsLabel.fontSize*1.25))
        countsLabel.name = Constants.countsLabelSpriteName
        countsLabel.zPosition = 1
        countsLabel.text = "White: 0  Black: 0"
        self.addChild(countsLabel)
    }
    
    func updateCountsLabel(white: Int, black: Int) {
        if let countsLabel = childNode(withName: Constants.countsLabelSpriteName)
            as! SKLabelNode? {
            countsLabel.text = "White  \(white) : \(black)  Black" }
    }
    
    // Alerts
    func displayAlert(text: String) {
        let alertLabel = SKLabelNode(fontNamed: Constants.appFont)
        alertLabel.fontSize = CGFloat(Constants.appFontSize)
        alertLabel.fontColor = SKColor.red
        alertLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.frame.midX + alertLabel.fontSize*0.25)
        alertLabel.name = Constants.alertSpriteName
        alertLabel.zPosition = 2
        alertLabel.text = text
        alertLabel.isUserInteractionEnabled = true
        self.addChild(alertLabel)
    }
    
    func removeAlert() {
        let alert = self.childNode(withName: Constants.alertSpriteName)
        alert?.removeFromParent()
    }
    
    // Atlas
    private func createAtlas() -> SKTextureAtlas {
        let images = Images()
        let dictionary = [
            Constants.ChipImages.whiteChip: images.whiteChipWithLight,
            Constants.ChipImages.blackChip: images.blackChipWithLight,
            Constants.cellImage: images.cellImage ]
        return SKTextureAtlas(dictionary: dictionary as [String : Any])
    }
    
    // Board
    private func displayEmptyBoard() {
        let boxSideLength = self.size.width/8
        let squareSize = CGSize(width: boxSideLength, height: boxSideLength)
        let yOffset: CGFloat = (self.size.height*0.25)
        for row in 0..<8 {
            let xOffset: CGFloat = (boxSideLength/2)
            for column in 0..<8 {
                let square = SKSpriteNode(
                    texture: atlas.textureNamed(Constants.cellImage),
                    size: squareSize)
                square.position = CGPoint(x: CGFloat(column) * squareSize.width + xOffset, y: CGFloat(row) * squareSize.height + yOffset)
                square.name = "\(row)\(column)"
                square.isUserInteractionEnabled = true
                self.addChild(square)
            }
        }
        drawCountsLabel()
    }
    
    // View
    func clearGameView() {
        for row in 0..<8 {
            for column in 0..<8 {
                if let cell = childNode(withName: "\(row)\(column)") as! SKSpriteNode? {
                    if cell.children.isEmpty {
                        continue
                    }
                    cell.removeAllChildren()
                }
            }
        }
    }
}
