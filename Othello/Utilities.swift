//
//  Utilities.swift
//  Othello
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

struct Constants {
    
    static let cellBackgroundImage = "board"
    static let cellImage = "CellImage"
    static let appFont = "Verdana"
    static let appFontSize = 30
    static let countsLabelSpriteName = "CountsLabel"
    static let alertSpriteName = "Alert"
    
    struct ChipImages {
        static let whiteChip = "WhiteChip"
        static let blackChip = "BlackChip"
    }
}

let gamePlayers = [Player(playerColor: .Black), Player(playerColor: .White)]

let directions: [(row: Int, column: Int)] =
[
(1,-1), (1,0), (1,1), // up-left, up, up-right
(0,-1),        (0,1), // left, right
(-1,-1), (-1,0), (-1,1) // down-left, down, down-right
]

let outOfBoardPosition = { return ($0 < 0) || ($0 > 7)}

func checkOneDirection(board: Board, _ color: CellType, _ row: Int, _ column: Int, _ direction: (row: Int, column: Int)) -> Move? {

    let opponentColor: CellType = (color == .White) ? .Black : .White
    
    var nextRow = row + direction.row
    if outOfBoardPosition(nextRow) {
        return nil
    }
    var nextColumn = column + direction.column
    if outOfBoardPosition(nextColumn) {
        return nil
    }
    
    if board[nextRow, nextColumn] != opponentColor {
        return nil
    }
    
    while board[nextRow, nextColumn] == opponentColor {
        nextRow += direction.row
        if outOfBoardPosition(nextRow) {
            return nil
        }
        nextColumn += direction.column
        if outOfBoardPosition(nextColumn) {
            return nil
        }
    }
    
    if board[nextRow, nextColumn] == color {
        return Move(row: nextRow, column: nextColumn)
    }
    return nil
}

func isValidMove(board: Board, color: CellType, row: Int, column: Int) -> Bool {
    if board[row, column] != .Empty {
        return false
    }
    for direction in directions {
        if checkOneDirection(board: board, color, row, column, direction) != nil {
            return true
        }
    }
    return false
}

func playerHasValidMoves(board: Board, _ player: Player) -> Bool {
    for row in 0..<8 {
        for column in 0..<8 {
            if isValidMove(board: board, color: player.color, row: row, column: column) {
                return true
            }
        }
    }
    return false
}

func gameEnded(board: Board, _ player: Player) -> Bool {
    if !playerHasValidMoves(board: board, player) && !playerHasValidMoves(board: board, player.opponent) { return true }
    else { return false }
}

// Count the number of valid moves for given player in a given board configuration
func countValidMoves(for player: Player, on board: Board) -> Double {
    var validMovesCounter = 0.0
    
    for row in 0..<8 {
        for column in 0..<8 {
            if isValidMove(board: board, color: player.color, row: row, column: column) {
                validMovesCounter += 1
            }
        }
    }
    return validMovesCounter
}

// Heuristic function for the game
// Evaluate score for a player
func dynamicHeuristicEvaluation(for player: Player, on board: Board) -> Double {
    var score = 0.0
    var playerDisks = 0.0, opponentDisks = 0.0, playerFrontierDisks = 0.0, opponentFrontierDisks = 0.0, playerMobility = 0.0, opponentMobility = 0.0
    
    let evaluationBoard: [[Double]] = [
    [1000, -500,  110,  80,  80, 110, -500,  1000],
    [-500, -800,  -40,  10,  10, -40, -800,  -500],
    [ 110,  -40,    2,   2,   2,   2,  -40,   110],
    [  80,   10,    2,  -3,  -3,   2,   10,    80],
    [  80,   10,    2,  -3,  -3,   2,   10,    80],
    [ 110,  -40,    2,   2,   2,   2,  -40,   110],
    [-500, -800,  -40,  10,  10, -40, -800,  -500],
    [1000, -500,  110,  80,  80, 110, -500,  1000]
    ]
    
    // 6. Disk squares
    var dBonus = 0.0
    for row in 0..<8 {
        for column in 0..<8 {
            if board[row, column] == player.color {
                dBonus += evaluationBoard[row][column]
                playerDisks += 1
            } else if board[row, column] == player.opponent.color {
                dBonus -= evaluationBoard[row][column]
                opponentDisks += 1
            }
            if board[row, column] != .Empty {
                var nextRow: Int, nextColumn: Int
                for direction in directions{
                    nextRow = row + direction.row
                    nextColumn = column + direction.column
                    if !outOfBoardPosition(nextRow) && !outOfBoardPosition(nextColumn) && board[nextRow, nextColumn] == .Empty {
                        if board[row,column] == player.color { playerFrontierDisks += 1 }
                        else { opponentFrontierDisks += 1 }
                        break
                    }
                }
            }
        }
        score += 75 * dBonus
        
        // 1. Piece difference
        var pBonus = 0.0
        if playerDisks > opponentDisks {
            pBonus = (100 * playerDisks) / (playerDisks + opponentDisks)
        }
        else if playerDisks < opponentDisks {
            pBonus = -(100 * opponentDisks) / (playerDisks + opponentDisks)
        }
        else {
            pBonus = 0
        }
        score += 100 * pBonus
        
        
        // 5. Frontier disk
        var fBonus = 0.0
        if playerFrontierDisks > opponentFrontierDisks {
            fBonus = -(100 * playerFrontierDisks) / (playerFrontierDisks + opponentFrontierDisks)
        }
        else if playerFrontierDisks < opponentFrontierDisks {
            fBonus = (100 * opponentFrontierDisks) / (playerFrontierDisks + opponentFrontierDisks)
        }
        else {
            fBonus = 0
        }
        score += 75 * fBonus
    }
    
    // 2. Corner occupancy
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
    score += 8000 * cBonus
    
    // 3. Corner closeness
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
    
    // 4. Mobility
    var mBonus = 0.0
    playerMobility = countValidMoves(for: player, on: board)
    opponentMobility = countValidMoves(for: player.opponent, on: board)
    if playerMobility == 0 || opponentMobility == 0 || playerMobility == opponentMobility {
        mBonus = 0
    }
    else if playerMobility > opponentMobility {
        mBonus = (100 * playerMobility) / (playerMobility + opponentMobility)
    }
    else if playerMobility < opponentMobility {
        mBonus = -(100 * opponentMobility) / (playerMobility + opponentMobility)
    }
    //score += 78.922 * mBonus
    score += 1000 * mBonus
    
    return score
}
