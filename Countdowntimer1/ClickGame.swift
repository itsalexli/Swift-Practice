//
//  ClickGame.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-19.
//

import SwiftUI

struct ClickGame: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var gm = ClickModel()
    private var background: Color {
        switch gm.color {
        case .green: .green
        case .white: .white
        case .red:   .red
        }
    }
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            VStack {
                Text(gm.message)
                    .font(.largeTitle).bold()
                    .foregroundStyle(background != .white ? .white : .black)
                    .padding()
                if let best = gm.highScore, gm.currState == ReactionState.result {     //if let cannot be unwrapped with a &&                 // only shows once there IS a best
                    Text("Best: \(best) ms").font(.title).bold()
                    .foregroundStyle(background != .white ? .white : .black)
                    
                }
            }
            
        }
        .onTapGesture {
            gm.tapped()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive {
                gm.reset()
            }
        }
        
    }
}

enum ReactionState {
    case idle
    case ready
    case result
    case tooSoon
}

enum screenColor {
    case green
    case white
    case red
}

@Observable
@MainActor
final class ClickModel {
    private var task: Task<Void, Never>? = nil
    
    private(set) var highScore: Int?
    private(set) var color = screenColor.white
    private(set) var currState: ReactionState = ReactionState.idle
    private(set) var message: String = "Start"
    
    private var startTime: Date =  Date()

    func tapped() {
        if currState == .idle {
            startTimer()
            message = ""
        }
        else if currState == .ready {
            let seconds = Date().timeIntervalSince(startTime)
            let ms = Int(seconds * 1000)
            message = "\(ms) ms. Tap to play again."
            currState = .result
            cancelTimer()
            highScore = min(highScore ?? ms, ms)
            
        }
        else if currState == .result {
            currState = .idle
            message = "Start"
            color = screenColor.white
        }
        else if currState == .tooSoon {
            message = "Clicked too soon. Click to play again."
            color = screenColor.white
            currState = .result
            cancelTimer()
        }
    }
    
    private func startTimer() {
        color = screenColor.red
        let delay = Double.random(in: 2...5)
        currState = .tooSoon
        task = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else {return}
            color = screenColor.green
            currState = .ready
            startTime = Date()
        }
    }
    
    private func cancelTimer() {
        task?.cancel()
        task = nil
    }
    
    func reset() {
        cancelTimer()
        currState = .idle
        message = "Start"
        color = .white
    }
}

#Preview {
    ClickGame()
}
