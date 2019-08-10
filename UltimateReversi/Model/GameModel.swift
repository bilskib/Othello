//
//  GameModel.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import GameplayKit

final class GameModel: NSObject, GKGameModel {
    
    var board = Board()
    var currentPlayer = gamePlayers[0]  // 0 - BLACK, 1 - WHITE
    let GKGameModelMaxScore = 5000
    let GKGameModelMinScore = -5000
    
    private func flipCells(row: Int, col: Int) {
        let playerColor = currentPlayer.color
        for dir in directions {
            if let move = checkOneDirection(board: board, playerColor, row, col, dir) {
                var nextRow = move.row - dir.row
                var nextCol = move.column - dir.col
                while (nextRow != row) || (nextCol != col) {
                    self.board[nextRow, nextCol] = playerColor
                    nextRow -= dir.row
                    nextCol -= dir.col
                }
            }
        }
    }
}

extension GameModel {
    
    var players: [GKGameModelPlayer]? {
        return gamePlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        let sourceModel = gameModel as! GameModel
        self.board = sourceModel.board
        self.currentPlayer = sourceModel.currentPlayer
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let player = player as! Player
        var moves = [Move]()
        for row in 0..<8 {
            for col in 0..<8 {
                if isValidMove(board: self.board, color: player.color, row: row, col: col) {
                    moves.append(Move(row: row, column: col))
                }
            }
        }
        player.numberOfMoves = moves.count
        if moves.isEmpty { return nil }
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! Move
        board[move.row, move.column] = currentPlayer.color
        flipCells(row: move.row, col: move.column)
        if playerHasValidMoves(board: board, currentPlayer.opponent){
            currentPlayer = currentPlayer.opponent
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = GameModel()
        copy.setGameModel(self)
        return copy
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        let player = player as! Player
        let playerScore = dynamicHeuristicEvaluation(for: player, on: board)
        return Int(playerScore)
    }
}
