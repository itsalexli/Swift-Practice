//
//  CountDownView.swift
//  MyApp
//
//  Created by Alexander Li on 2026-11-17.
//


//scenestate, state, bpdy, text, task. then guard check if its active. check if isCancelled or not
    //check if its okay using task cancelld or not

//try? await task sleep
//if the task is cancelled break

import SwiftUI

struct CountDownView: View {
    @State private var secondsLeft = 10
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        Text("\(secondsLeft)").font(.largeTitle)
            .task (id: scenePhase){
                guard scenePhase == .active else {return}
                while !Task.isCancelled && secondsLeft > 0 {
                    try? await Task.sleep(for: .seconds(1))
                    secondsLeft -= 1
                    print("\(secondsLeft)")
                    if Task.isCancelled {break}
                }
            }
            .onAppear {print("Appeared")}
            .onDisappear {print("Dissapeared")}
    }
}


#Preview {
    CountDownView()
}
