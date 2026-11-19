//
//  CountDownGame.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-18.
//
import SwiftUI


struct HomeView: View {
    @State private var gm = GameModel()

    var body: some View {
        NavigationLink("Play"){
            CountDownGame(gm: gm)
        }
        .navigationTitle("Home")
    }
}

struct CountDownGame: View {
    @Environment(\.scenePhase) private var scenePhase
    let gm: GameModel
    var body: some View {
        
        VStack {
            Text("Score \(gm.score)").font(.largeTitle).padding()
            Text("Time Left: \(gm.secondsLeft)")
            Button("Tap!") {gm.tap()}
                .disabled (gm.currState != .playing)
            
            switch gm.currState {
            case .gameOver:
                Button("Play Again") {gm.reset()}
            case .idle:
                Button("Start") {gm.start()}
            case .playing:
                Button("Pause") {gm.pause()}
            case .paused:
                Button("Resume") {gm.resume()}
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background { gm.pause()}
        }
    }
}
@MainActor
@Observable
final class GameModel {
    enum GameState {case idle, playing, paused, gameOver}
    var currState = GameState.idle
    var score = 0
    var secondsLeft = 10
    
    private var task: Task<Void, Never>?
    
    private func runTimer() {
        task = Task {
            while !Task.isCancelled && secondsLeft > 0{
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                secondsLeft -= 1
                if secondsLeft == 0 {
                    currState = .gameOver
                    task = nil
                }
                print("tick")
            }
        }
    }
    
    func start() {
        guard currState == .idle else {return}
        currState = .playing
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
    
    func tap() {
        guard currState == .playing else {return}
        score += 1
    }
    
    func reset() {
        guard currState == .gameOver else {return}
        score = 0
        secondsLeft = 10
        currState = .idle
    }
}

#Preview {
    CountDownGame(gm: GameModel())
}
