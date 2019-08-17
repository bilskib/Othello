//
//  Move.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import GameplayKit

final class Move: NSObject, GKGameModelUpdate {
    
    private var score = 0
    let row: Int
    let column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
        super.init()
    }
}

// Required by GKGameModelUpdate protocol
extension Move {
    
    var value: Int {
        get { return score }
        set { score = newValue }
    }
}
