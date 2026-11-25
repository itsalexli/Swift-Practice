import SwiftUI

struct TradeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var tm = TradeModel()

    var body: some View {
        VStack(spacing: 24) {
            // MARK: Header
            Text("Mock Trader")
                .font(.headline)

            Label("\(tm.timeLeft)s", systemImage: "timer")
                .font(.headline.monospacedDigit())
                .foregroundStyle(tm.timeLeft <= 5 ? .red : .primary)

            Spacer()

            // MARK: Price
            Text("\(tm.currPrice, format: .currency(code: "USD"))")
                .font(.system(size: 56, weight: .bold).monospacedDigit())

            // MARK: Buy / Sell
            HStack(spacing: 12) {
                Button { tm.buyStock() } label: {
                    Text("BUY")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .tint(.green)

                Button { tm.sellStock() } label: {
                    Text("SELL")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .tint(.red)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .disabled(tm.currState != .playing)

            Spacer()

            // MARK: Cash + Shares card
            HStack {
                VStack {
                    Text("CASH").font(.caption).foregroundStyle(.secondary)
                    Text("\(tm.currCash, format: .currency(code: "USD"))")
                        .font(.title2).bold().monospacedDigit()
                }
                Spacer()
                VStack {
                    Text("SHARES").font(.caption).foregroundStyle(.secondary)
                    Text("\(tm.currShares)")
                        .font(.title2).bold().monospacedDigit()
                }
            }
            .padding()
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // MARK: Start / Play Again
            if tm.currState != .playing {
                Button {
                    tm.runGame()
                } label: {
                    Text(tm.currState == .start ? "Start" : "Play Again")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 8))
            }
        }
        .padding()
        .alert("Game Over", isPresented: $tm.showAlert) {
            Button("Play Again") { tm.runGame() }
            Button("Exit", role: .cancel) { }
        } message: {
            Text("Final Cash: \(tm.currCash, format: .currency(code: "USD"))\nFinal Net Worth: \(tm.netWorth, format: .currency(code: "USD"))\nGain/Loss: \(tm.gainLoss, format: .currency(code: "USD"))")
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                tm.resume()
            } else {
                tm.pause()          // .inactive or .background
            }
        }
    }
}

enum GameState { case start, playing, result }

@MainActor
@Observable
final class TradeModel {
    private(set) var timeLeft: Int = 15
    private(set) var currPrice: Double = 42.0
    private(set) var currCash: Double = 1000.0
    private(set) var currShares: Int = 0
    private(set) var currState = GameState.start
    var showAlert = false                       // plain var: bound with $

    var netWorth: Double { currCash + Double(currShares) * currPrice }
    var gainLoss: Double { netWorth - 1000 }

    private var task: Task<Void, Never>?

    // MARK: Game flow
    func runGame() {
        guard currState != .playing else { return }
        resetItems()                            // state first
        startTimer()                            // then launch
    }

    func pause() {
        task?.cancel()                          // stop ticking, keep state
        task = nil
    }

    func resume() {
        guard currState == .playing, task == nil else { return }
        startTimer()                            // continues from current timeLeft
    }

    private func endGame() {
        pause()
        currState = .result
        showAlert = true
    }

    private func startTimer() {
        task?.cancel()                          // never run two timers
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                changePrice()
                timeLeft -= 1
                if timeLeft <= 0 {
                    endGame()
                    return
                }
            }
        }
    }

    private func resetItems() {
        showAlert = false
        currState = .playing
        timeLeft = 15
        currPrice = 42.0
        currCash = 1000
        currShares = 0
    }

    // MARK: Trading
    func changePrice() {
        guard currState == .playing else { return }
        let change = Double.random(in: -5.0...5.0)
        currPrice = max(0, currPrice + change)
        currPrice = (currPrice * 100).rounded() / 100
    }

    func buyStock() {
        guard currState == .playing, currCash >= currPrice else { return }
        currCash -= currPrice
        currShares += 1
    }

    func sellStock() {
        guard currState == .playing, currShares > 0 else { return }
        currCash += currPrice
        currShares -= 1
    }
}

#Preview {
    TradeView()
}
