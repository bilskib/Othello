//
//  Board.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

enum CellType: Int {
    case Empty, White, Black
}

struct Board {
    var grid = [CellType](repeating: .Empty, count: 64)
    
    subscript (row: Int, column: Int) -> CellType {
        get { return grid[row * 8 + column] }
        set { grid[row * 8 + column] = newValue }
    }
}

let numberOfCells = { (board: Board, color: CellType) -> Int in
    return board.grid.filter({$0 == color}).count
}
