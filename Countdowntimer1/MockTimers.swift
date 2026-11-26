//
//  MockTimers.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-24.
//
//
//Build a one-page app with a list of 50 rows. Each row is a timer. Rows that are visible on screen should be counting. When a row scrolls off the screen, its timer should stop, and when it comes back, it should start again. Tapping a row toggles its timer. If time permits, add a red dot on the left of each row that blinks, and then let's talk about how you'd optimize it

//One more detail I'll volunteer: "Show the time in seconds with one decimal place, updating every 0.1 seconds."

//"Should state persist if the app is fully closed and reopened?

//question: what happens if the user clicks off the app or phone call happens? do all timers start at the same time? will they ever reset, or start back to its original time? Should they all start off and wait for the toggle, or should they start on>


//timerListView: scenePhase, @state of timerlist model, list of timer views

//timerView: currTime = 0, id, label: Str, isPaused

//timerListModel: array of timers holding their current times?


//tick timer (timer ID)
//togglePause

//func ontap
//onScreen and offscreen? --> how do I do that did I learn that -->

//1. Yes, you learned on-screen/off-screen. It's lesson #1 from the timer lesson: put a .task on each row. List creates rows lazily, so the task starts when the row scrolls on screen and is auto-cancelled when it scrolls off. (.onAppear / .onDisappear also exist if you want to call model functions instead.)

//import SwiftUI
//struct TimerListView: View {
//    @State private var tm = TimerListModel()
//    
//    var body: some View {
//        VStack {
//            Text("Timer List").font(.largeTitle).bold().padding()
//            List {
//                ForEach(tm.timerArr) { timerItem in
//                    TimerRow(timer: timerItem)
//                }
//            }
//        }
//    }
//}
//
//q
//struct TimerRow: View {
//    @Environment(\.scenePhase) private var scenePhase
//    
//    private var isRunning: Bool { !timer.isPaused && scenePhase == .active }
//    
//    let timer: TimerItem
//    
//    var body: some View {
//        HStack {
//            Circle()
//                .fill(.red)
//                .frame(width: 10, height: 10)
//                .opacity(isRunning ? 1.0 : 0.2)
//            Text("Row \(timer.id + 1)")
//            Spacer()
//            Text(timer.time, format: .number.precision(.fractionLength(1)))
//                .monospacedDigit()
//        }
//        .task(id: isRunning){
//            guard isRunning else {return}
//            await timer.tick()
//        }
//        .contentShape(Rectangle())
//        .onTapGesture {
//            timer.togglePause()
//            
//
//        }
//    }
//}
//
//@MainActor
//@Observable
//final class TimerListModel {
//    let timerArr: [TimerItem] = (0..<50).map { TimerItem(id: $0) }
//    
//    }
//
//
//#Preview {
//    TimerListView()
//}
//    


import SwiftUI

@MainActor
@Observable
final class TimerItem: Identifiable{
    let id: Int
    var time: Double
    var isRunning: Bool
    
    init(id: Int) {
        self.id = id
        self.time = 0.0
        self.isRunning = true
    }
    
    func tick() async{
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(100))
            guard !Task.isCancelled else {return}
            time += 0.1        }
    }
    
    func togglePause() {
        isRunning.toggle()
    }
}

struct TimerRow: View {
    @Environment(\.scenePhase) private var scenePhase
    let timer: TimerItem
    var body: some View {
        HStack {
            Text("Timer \(timer.id)").font(.title3).bold()
            Spacer()
            Text(timer.time, format: .number.precision(.fractionLength(1)))
                .font(.title3).bold()
                .monospacedDigit()
        }
        .padding()
        .contentShape(Rectangle())
        .task (id: timer.isRunning && scenePhase == .active){
            guard timer.isRunning, scenePhase == .active else {return}
            await timer.tick()
        }
        .onTapGesture {
            timer.togglePause()
        }
    }
}

struct TimerListView: View {
    @State private var tm = TimerModel()
    var body: some View {
        VStack {
            Text("Timer Lists").font(.title).bold().padding()
            List {
                ForEach(tm.timerArr) { timer in
                    TimerRow(timer: timer)
                }
            }
            
        }
    }
}

@MainActor
@Observable
final class TimerModel {
    let timerArr: [TimerItem] = (1...50).map { TimerItem(id: $0)}
}
#Preview {
    TimerListView()
}
