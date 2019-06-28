//
//  GameLogic.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import GameplayKit

final class GameLogic {
    
    private var gameScene: GameLogicUI
    private var gameModel = GameModel()
    private var alertActive = false
    
    private func addChip(color: CellType, row: Int, column: Int) {
        gameScene.displayChip(color: color, row: row, column: column)
        gameModel.board[row, column] = color
    }
    
    private func flipCells(row: Int, col: Int) {
        let playerColor = gameModel.currentPlayer.color
        for dir in directions {
            if let move = checkOneDirection(board: gameModel.board, playerColor, row, col, dir) {
                
                // valid move found, go back and flip
                var nextRow = move.row - dir.row
                var nextCol = move.column - dir.col
                while (nextRow != row) || (nextCol != col) {
                    gameModel.board[nextRow, nextCol] = playerColor
                    gameScene.updateChip(color: playerColor, nextRow, nextCol)
                    nextRow -= dir.row
                    nextCol -= dir.col
                }
            }
        }
    }
    
    func gameIsFinished() -> Bool {
        return !playerHasValidMoves(board: gameModel.board, gameModel.currentPlayer) && !playerHasValidMoves(board: gameModel.board, gameModel.currentPlayer.opponent)
    }
    
    private func makeMove(row: Int, col: Int) {
        addChip(color: gameModel.currentPlayer.color, row: row, column: col)
        flipCells(row: row, col: col)
        let white = numberOfCells(gameModel.board, .White)
        let black = numberOfCells(gameModel.board, .Black)
        gameScene.updateCountsLabel(white: white, black: black)
        gameModel.currentPlayer = gameModel.currentPlayer.opponent
        
        if gameIsFinished() {
            alertActive = true
            var resultText: String
            switch white-black {
            case 1...64:
                resultText = "White win"
            case 0:
                resultText = "Draw"
            default:
                resultText = "Black win"
            }
            gameScene.displayAlert(text: resultText)
            return
        }
        
        if playerHasValidMoves(board: gameModel.board, gameModel.currentPlayer) {
            if gameModel.currentPlayer == gamePlayers[0] {
                return // wait for human move
            } else {
                aiMove() // let AI work
            }
        } else { // player must pass
            alertActive = true
            gameScene.displayAlert(
                text: "\(gameModel.currentPlayer.color) have to pass!")
        }
    }
    
    private func aiMove() {
        let strategist = GKMinmaxStrategist()
        strategist.gameModel = gameModel
        
        //let sharedRandomSource = GKRandomSource.sharedRandom()
        let arc4RandomSource = GKARC4RandomSource() // balanced speed & randomness
        //let linearCongruential = GKLinearCongruentialRandomSource() // faster, less random
        //let mersenneTwister = GKMersenneTwisterRandomSource() // slower, more random
        
        strategist.randomSource = arc4RandomSource
        //strategist.randomSource = mersenneTwister
        strategist.maxLookAheadDepth = 5
        
        gameScene.showAIIndicator(yes: true)
        let myDispatchWorkItem = DispatchWorkItem(qos: .userInitiated, flags: .noQoS, block: {
            //let move = strategist.bestMoveForActivePlayer() as! Move
            let move = strategist.bestMove(for: self.gameModel.currentPlayer) as! Move
            DispatchQueue.main.async {
                self.gameScene.showAIIndicator(yes: false)
                self.makeMove(row: move.row, col: move.column)
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: myDispatchWorkItem)
    }
    
    func cellPressed(row: Int, _ column: Int) {
        if alertActive { // pass or game over
            alertActive = false
            gameScene.removeAlert()
            if gameIsFinished() {
                setInitialBoard()
                return
            }
            gameModel.currentPlayer = gameModel.currentPlayer.opponent
            if gameModel.currentPlayer == gamePlayers[1] {
                aiMove() // let AI work
            }
            return
        }
        if (row == -1) && (column == -1) {
            return // allow user to click in any place after alert
        }
        if gameModel.currentPlayer == gamePlayers[0] {
            if isValidMove(board: gameModel.board, color: gameModel.currentPlayer.color,
                           row: row, col: column) {
                makeMove(row: row,col: column)
            }
        }
    }
    
    func setInitialBoard() {
        gameScene.clearGameView() // clear results of previous game
        for row in 0..<8 {
            for col in 0..<8 {
                switch (row,col) {
                case (3,3),(4,4) :
                    addChip(color: .Black, row: row, column: col)
                case (3,4),(4,3) :
                    addChip(color: .White, row: row, column: col)
                default:
                    gameModel.board[row,col] = .Empty
                }
            }
        }
        gameScene.updateCountsLabel(white: 2,black: 2)
        gameModel.currentPlayer = gamePlayers[0]
    }
    
    init(scene: GameLogicUI) {
        self.gameScene = scene
    }
    
}
