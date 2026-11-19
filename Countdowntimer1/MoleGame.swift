//
//  MoleGame.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-18.
//

import SwiftUI

struct MoleGame: View {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    @State private var gm = MoleModel()
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        VStack {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<9, id: \.self) { index in
                    Button {
                        gm.tapCell(index: index)
                    } label: {
                        Rectangle()
                            .fill(index == gm.highlighted ? .green : .gray)
                            .frame(width: 50, height: 50)
                    }
                    .disabled(gm.currState != .playing)
                    
                }
            }.padding(.bottom, 100)
            Text("Score: \(gm.score)").font(.largeTitle).padding(.bottom)
            Text("Time: \(gm.timeLeft)").font(.largeTitle).padding(.bottom)
            
            switch gm.currState {
            case .gameOver:
                Button("Reset"){gm.reset()}
            case .idle:
                Button("Start"){gm.start()}
            case .paused:
                Button("Resume"){gm.resume()}
            case .playing:
                Button("Pause"){gm.pause()}
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive {
                gm.pause()
            }
        }
    }
}


enum GameMode {case idle, playing, paused, gameOver}

@Observable
@MainActor
final class MoleModel {
    private var task: Task<Void, Never>?
    private(set) var timeLeft = 10
    private(set) var currState = GameMode.idle
    private(set) var score = 0
    private(set) var highlighted: Int? = nil
    
    func tapCell(index: Int) {
        guard currState == .playing else {return}
        if index == highlighted {
            score += 1
            highlighted = nil
        }
    }
    
    private func setMole() {
        highlighted = Int.random(in: 0..<9)
    }
    
    private func runTimer() {
        task = Task {
            while !Task.isCancelled && timeLeft > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled {break}
                setMole()
                timeLeft -= 1
                if timeLeft == 0 {
                    currState = .gameOver
                    highlighted = nil
                    task = nil
                }
            }
        }
    }
    
    func start() {
        guard currState == .idle else {return}
        currState = .playing
        setMole()
        runTimer()
    }
    
    func pause() {
        guard currState == .playing else {return}
        task?.cancel()
        task = nil
        currState = .paused
    }
    
    func resume() {
        guard currState == .paused else {return}
        currState = .playing
        runTimer()
        
    }
    func reset() {
        guard currState == .gameOver else {return}
        currState = .idle
        score = 0
        timeLeft = 10
    }
}

#Preview {
    MoleGame()
}
