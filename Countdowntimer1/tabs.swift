//import SwiftUI
//
//struct Card: Identifiable{
//    let id = UUID()
//    let color: Color
//    let title: String
//    let subtitle: String
//}
//
//@MainActor
//@Observable
//final class CarouselModel {
//    var autoscroll: Bool = false
//    
//    let datasets: [[Card]] = [
//        [
//            Card(color: .red,    title: "Red",    subtitle: "Card 1"),
//            Card(color: .green,  title: "Green",  subtitle: "Card 2"),
//            Card(color: .blue,   title: "Blue",   subtitle: "Card 3"),
//        ],
//        [
//            Card(color: .orange, title: "Orange", subtitle: "Card 1"),
//            Card(color: .purple, title: "Purple", subtitle: "Card 2"),
//        ],
//        [
//            Card(color: .teal,   title: "Teal",   subtitle: "Card 1"),
//            Card(color: .pink,   title: "Pink",   subtitle: "Card 2"),
//            Card(color: .indigo, title: "Indigo", subtitle: "Card 3"),
//            Card(color: .brown,  title: "Brown",  subtitle: "Card 4"),
//        ],
//    ]
//    
//    private(set) var datasetNum = 0
//    var currCards: [Card] {
//        datasets[datasetNum]
//    }
//    var cardNum = 0
//    
//    func selectDataset(newDataset: Int) {
//        if datasets.indices.contains(newDataset) {
//            datasetNum = newDataset
//            cardNum = 0
//        }
//    }
//    
//    func advance() {
//        guard !currCards.isEmpty else { return }
//        cardNum = (cardNum + 1) % currCards.count
//        
//    }
//}
//
//
//struct CardView: View {
//    let card: Card
//    var body: some View {
//        RoundedRectangle(cornerRadius: 16)
//            .fill(card.color)
//            .overlay(alignment: .center) {
//                VStack {
//                    Text(card.title).fontWeight(.bold).font(.title)
//                    Text(card.subtitle)
//                }
//                .foregroundStyle(.white)
//                .padding(16)
//            }
//    }
//    
//}
//
//
//struct CarouselView: View {
//    @Environment(\.scenePhase) private var scenePhase
//    @State private var cm = CarouselModel()
//    
//    private var shouldScroll: Bool {
//        cm.autoscroll && scenePhase == .active
//    }
//    
//    var body: some View {
//        VStack {
//            TabView (selection: $cm.cardNum){ //TAB VIEW WRITES TO THIS WHEN SWIPED
//                ForEach(cm.currCards.enumerated(), id: \.element.id) { index, card in
//                    CardView(card: card).tag(index)
//                }
//            }
//            .tabViewStyle(.page)
//            .frame(height: 220)
//            .padding(50)
//            
//            Toggle("Autoscroll", isOn: $cm.autoscroll)
//                .padding(.horizontal, 115)
//                .padding(.bottom, 50)
//                .font(.title2)
//            
//            ForEach(cm.datasets.indices, id: \.self) { index in
//                Button("Dataset \(index + 1)") {
//                    cm.selectDataset(newDataset: index)
//                }
//                .padding(.top, 1)
//                .font(.title2)
//                
//            }
//        }
//        .task(id: shouldScroll) {
//            guard shouldScroll else { return }
//            while !Task.isCancelled {
//                try? await Task.sleep(for: .seconds(2))
//                if Task.isCancelled {break}
//                withAnimation{cm.advance()}
//            }
//        }
//    }
//}
//
//
//
//
//
//
//
//
//
////
////  Mock3Carousel.swift
////  Countdowntimer1
////
////  Created by Alexander Li on 2026-11-26.
////
////
////The Problem
////We're building a screen with a horizontally swipeable card carousel in the middle and three buttons at the bottom that switch between three different sets of cards (with 3, 2, and 4 cards).
////Each card shows a background color, a rounded rectangle shape, and a title and subtitle aligned to the bottom-left. Swiping horizontally should page cleanly from card to card with spacing between adjacent cards. When the user taps one of the three dataset buttons, the carousel switches to that dataset and resets back to the first card.
////As a follow-up, add a toggle/switch that automatically advances to the next card every 2 seconds when turned on, wrapping back to the first card after the last one. Auto-scroll shouldn't run when turned off or when the screen isn't visible, and switching datasets should restart the timer cleanly from the first card without any retain cycles.
////(Note: Since you build in SwiftUI and are prepping for both your screen and onsite, you can build this in SwiftUI or explain how you'd approach it—and remember to restate the problem in your own words, ask clarifying questions, state your assumptions, and walk through your plan before coding.)
//
//
//
//
//
//
//
//
