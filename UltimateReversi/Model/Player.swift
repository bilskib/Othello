//
//  Player.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import GameplayKit

final class Player: NSObject, GKGameModelPlayer {
    
    private let id: Int
    var playerId: Int { return id}
    
    let color: CellType
    
    var opponent: Player {
        if self.color == .White { return gamePlayers[0] }
        else { return gamePlayers[1] }
    }
    
    private var mobility = 0
    var numberOfMoves: Int {
        get { return mobility }
        set { mobility = newValue }
    }
    
    init(playerColor: CellType) {
        self.color = playerColor
        self.id = playerColor.rawValue
        super.init()
    }
}
