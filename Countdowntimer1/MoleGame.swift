//
//  MoleGame.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-18.
//

import SwiftUI

struct HomView: View {
    @State private var gm = MoleModel()
    var body: some View {
        NavigationLink("Play") {
            MoleGame(gm: gm)
        }
    }
}


struct MoleGame: View {
    let gm: MoleModel
    var body: some View {
        
    }
}


enum GameMode {case idle, playing, paused, gameOver}

@Observable
final class MoleModel {
    private var task: Task<Void, Never>?
    var timeLeft = 30
    var currState = GameMode.idle
    var score = 0
}




#Preview {
    MoleGame(gm: MoleModel())
}
