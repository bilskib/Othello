//
//  Common.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

let gamePlayers = [Player(playerColor: .Black),Player(playerColor: .White)]

let directions: [(row: Int, col: Int)] =
[
(1,-1), (1,0), (1,1), // up-left, up, up-right
(0,-1),        (0,1), // left, right
(-1,-1), (-1,0), (-1,1) // down-left, down, down-right
]

func checkOneDirection(board: Board, _ color: CellType, _ row: Int, _ col: Int, _ dir: (row: Int, col: Int)) -> Move? {
    
    let positionOutOfRange = { return ($0 < 0) || ($0 > 7)}
    let opponentColor: CellType = (color == .White) ? .Black : .White
    
    var nextRow = row + dir.row
    if positionOutOfRange(nextRow) {
        return nil
    }
    var nextCol = col + dir.col
    if positionOutOfRange(nextCol) {
        return nil
    }
    
    if board[nextRow, nextCol] != opponentColor {
        return nil
    }
    
    while board[nextRow, nextCol] == opponentColor {
        nextRow += dir.row
        if positionOutOfRange(nextRow) {
            return nil
        }
        nextCol += dir.col
        if positionOutOfRange(nextCol) {
            return nil
        }
    }
    
    if board[nextRow, nextCol] == color {
        return Move(row: nextRow, column: nextCol)
    }
    return nil
}

func isValidMove(board: Board, color: CellType, row: Int, col: Int) -> Bool {
    if board[row, col] != .Empty {
        return false
    }
    for dir in directions {
        if checkOneDirection(board: board, color, row, col, dir) != nil {
            return true
        }
    }
    return false
}

func playerHasValidMoves(board: Board, _ player: Player) -> Bool {
    for row in 0..<8 {
        for col in 0..<8 {
            if isValidMove(board: board, color: player.color, row: row, col: col) {
                return true
            }
        }
    }
    return false
}

func gameEnded(board: Board, _ player: Player) -> Bool {
    if !playerHasValidMoves(board: board, player) && !playerHasValidMoves(board: board, player.opponent) { return true } else { return false }
}


// Heuristic function for the game
// 1. Count the number of valid moves for given player in a given board configuration

func countValidMoves(for player: Player, on board: Board) -> Double {
    var validMovesCounter = 0.0
    
    for row in 0..<8 {
        for column in 0..<8 {
            if isValidMove(board: board, color: player.color, row: row, col: column) {
                validMovesCounter += 1
            }
        }
    }
    return validMovesCounter
}

// 2. Evaluate score for a player

func dynamicHeuristicEvaluation(for player: Player, on board: Board) -> Double {
    var score = 0.0
    var playerDisks = 0.0, opponentDisks = 0.0, playerFrontDisks = 0.0, opponentFrontDisks = 0.0
    let dirX = [-1, -1, 0, 1, 1,  1,  0, -1]
    let dirY = [ 0,  1, 1, 1, 0, -1, -1, -1]
    
    let evalBoard: [[Double]] = [
    [20, -3, 11,  8,  8, 11, -3, 20],
    [-3, -7, -4,  1,  1, -4, -7, -3],
    [11, -4,  2,  2,  2,  2, -4, 11],
    [8,   1,  2, -3, -3,  2,  1,  8],
    [8,   1,  2, -3, -3,  2,  1,  8],
    [11, -4,  2,  2,  2,  2, -4, 11],
    [-3, -7, -4,  1,  1, -4, -7, -3],
    [20, -3, 11,  8,  8, 11, -3, 20]
    ]
    
    // Disk amount bonus
    // Piece difference, frontier disks and disk squares
    var dBonus = 0.0
    
    for row in 0..<8 {
        for column in 0..<8 {
            if board[row, column] == player.color {
                dBonus += evalBoard[row][column]
                playerDisks += 1
            } else if board[row, column] == player.opponent.color {
                dBonus -= evalBoard[row][column]
                opponentDisks += 1
            }
            if board[row, column] != .Empty {
                var x: Int, y: Int
                
                for index in 0..<8 {
                    x = row + dirX[index]
                    y = column + dirY[index]
                    if x >= 0 && x < 8 && y >= 0 && y < 8 && board[x, y] == .Empty {
                        if board[row, column] == player.color { playerFrontDisks += 1 }
                        else { opponentFrontDisks += 1 }
                        break
                    }
                }
            }
        }
        
        var pBonus = 0.0
        if playerDisks > opponentDisks { pBonus = (100 * playerDisks) / (playerDisks + opponentDisks) }
        else if playerDisks < opponentDisks { pBonus = -(100 * opponentDisks) / (playerDisks + opponentDisks) }
        else { pBonus = 0 }
        
        score = 10 * pBonus
        
        var fBonus = 0.0
        if playerFrontDisks > opponentFrontDisks { fBonus = -(100 * playerFrontDisks) / (playerFrontDisks + opponentFrontDisks) }
        else if playerFrontDisks < opponentFrontDisks { fBonus = (100 * opponentFrontDisks) / (playerFrontDisks + opponentFrontDisks) }
        else { fBonus = 0 }
        
        //score += 74.396 * fBonus
        score += 74 * fBonus
    }
    
    // Corner occupancy
    playerDisks = 0
    opponentDisks = 0
    
    if board[0, 0] == player.color { playerDisks += 1 }
    else if board[0, 0] == player.opponent.color { opponentDisks += 1 }
    if board[0, 7] == player.color { playerDisks += 1 }
    else if board[0, 7] == player.opponent.color { opponentDisks += 1 }
    if board[7, 0] == player.color { playerDisks += 1 }
    else if board[7, 0] == player.opponent.color { opponentDisks += 1 }
    if board[7, 7] == player.color { playerDisks += 1 }
    else if board[7, 7] == player.opponent.color { opponentDisks += 1 }
    let cBonus = 25 * (playerDisks - opponentDisks)
    
    //score += 801.724 * cBonus
    score += 801 * cBonus
    
    // Corner closeness
    playerDisks = 0
    opponentDisks = 0
    
    if board[0, 0] == .Empty {
        if board[0, 1] == player.color { playerDisks += 1 }
        else if board[0, 1] == player.opponent.color { opponentDisks += 1 }
        if board[1, 1] == player.color { playerDisks += 1 }
        else if board[1, 1] == player.opponent.color { opponentDisks += 1 }
        if board[1, 0] == player.color { playerDisks += 1 }
        else if board[1, 0] == player.opponent.color { opponentDisks += 1 }
    }
    if board[0, 7] == .Empty {
        if board[0, 6]  == player.color { playerDisks += 1 }
        else if board[0, 6] == player.opponent.color { opponentDisks += 1 }
        if board[1, 6] == player.color { playerDisks += 1 }
        else if board[1, 6] == player.opponent.color { opponentDisks += 1 }
        if board[1, 7] == player.color { playerDisks += 1 }
        else if board[1, 7] == player.opponent.color { opponentDisks += 1 }
    }
    if board[7, 0] == .Empty {
        if board[7, 1] == player.color { playerDisks += 1 }
        else if board[7, 1] == player.opponent.color { opponentDisks += 1 }
        if board[6, 1] == player.color { playerDisks += 1 }
        else if board[6, 1] == player.opponent.color { opponentDisks += 1 }
        if board[6, 0] == player.color { playerDisks += 1 }
        else if board[6, 0] == player.opponent.color { opponentDisks += 1 }
    }
    if board[7, 7] == .Empty {
        if board[6, 7] == player.color { playerDisks += 1 }
        else if board[6, 7] == player.opponent.color { opponentDisks += 1 }
        if board[6, 6] == player.color { playerDisks += 1 }
        else if board[6, 6] == player.opponent.color { opponentDisks += 1 }
        if board[7, 6] == player.color { playerDisks += 1 }
        else if board[7, 6] == player.opponent.color { opponentDisks += 1 }
    }
    let lBonus = -12.5 * (playerDisks - opponentDisks)
    
    //score += 382.026 * lBonus
    score += 382 * lBonus
    
    // Mobility
    var mBonus = 0.0
    playerDisks = countValidMoves(for: player, on: board)
    opponentDisks = countValidMoves(for: player.opponent, on: board)
    
    if playerDisks > opponentDisks { mBonus = (100 * playerDisks) / (playerDisks + opponentDisks) }
    else if playerDisks < opponentDisks { mBonus = -(100 * opponentDisks) / (playerDisks + opponentDisks) }
    
    //score += 78.922 * mBonus
    score += 79 * mBonus
    
    return score
}
