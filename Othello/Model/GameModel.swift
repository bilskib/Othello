//
//  GameModel.swift
//  Othello
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import GameplayKit

final class GameModel: NSObject, GKGameModel {
    
    var board = Board()
    var currentPlayer = gamePlayers[0]  // 0 - BLACK, 1 - WHITE
    let GKGameModelMaxScore = 100000
    let GKGameModelMinScore = -100000
    
    private func flipCells(row: Int, column: Int) {
        let playerColor = currentPlayer.color
        for direction in directions {
            if let move = checkOneDirection(board: board, playerColor, row, column, direction) {
                var nextRow = move.row - direction.row
                var nextColumn = move.column - direction.column
                while (nextRow != row) || (nextColumn != column) {
                    self.board[nextRow, nextColumn] = playerColor
                    nextRow -= direction.row
                    nextColumn -= direction.column
                }
            }
        }
    }
}

// Required by GKGameModel protocol
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
            for column in 0..<8 {
                if isValidMove(board: self.board, color: player.color, row: row, column: column) {
                    moves.append(Move(row: row, column: column))
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
        flipCells(row: move.row, column: move.column)
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
