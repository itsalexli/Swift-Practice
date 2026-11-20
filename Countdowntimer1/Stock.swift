import SwiftUI


//create struct for
struct PriceUpdate {
    let ticker: String
    let price: Double
}
//create stock with ID (identifiable), ticker, price, prev price
struct Stock: Identifiable {
    let ticker: String
    var price: Double
    var previousPrice: Double
    var id: String { ticker }
}

extension Stock {
    var isUp: Bool { price >= previousPrice }
}

//interface for price service
protocol PriceService {
    func priceUpdates() -> AsyncStream<PriceUpdate>
}


//service for the thing
final class MockPriceService: PriceService {
    private let tickers = ["HOOD", "AAPL", "NVDA", "TSLA", "MSFT"]

    func priceUpdates() -> AsyncStream<PriceUpdate> {
        AsyncStream { continuation in
            var prices: [String: Double] = [
                "HOOD": 42, "AAPL": 228, "NVDA": 141,
                "TSLA": 352, "MSFT": 415
            ]

            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(500))

                    guard let ticker = tickers.randomElement(),
                          let current = prices[ticker] else { continue }

                    let newPrice = max(1, current + Double.random(in: -2...2))
                    prices[ticker] = newPrice

                    print("yield \(ticker)")
                    continuation.yield(PriceUpdate(ticker: ticker, price: newPrice))
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                print("producer stopped")
                task.cancel()
            }
        }
    }
}

@MainActor
@Observable
final class WatchlistModel {
    private(set) var stocks: [Stock] = [
        Stock(ticker: "HOOD", price: 42, previousPrice: 42),
        Stock(ticker: "AAPL", price: 228, previousPrice: 228),
        Stock(ticker: "NVDA", price: 141, previousPrice: 141),
        Stock(ticker: "TSLA", price: 352, previousPrice: 352),
        Stock(ticker: "MSFT", price: 415, previousPrice: 415)
    ]

    private let service: PriceService

    init(service: PriceService) {
        self.service = service
    }

    func listen() async {
        for await update in service.priceUpdates() {
            apply(update)
        }
    }

    private func apply(_ update: PriceUpdate) {
        guard let index = stocks.firstIndex(where: { $0.ticker == update.ticker }) else { return }
        stocks[index].previousPrice = stocks[index].price
        stocks[index].price = update.price
    }
}

struct WatchlistView: View {
    @State private var model = WatchlistModel(service: MockPriceService())
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List(model.stocks) { stock in
                HStack {
                    Text(stock.ticker)
                        .font(.headline)
                    Spacer()
                    Text(stock.price, format: .currency(code: "USD"))
                    Image(systemName: stock.isUp ? "arrow.up" : "arrow.down")
                }
                .foregroundStyle(stock.isUp ? .green : .red)
            }
            .navigationTitle("Watchlist")
            .task(id: scenePhase) {
                guard scenePhase == .active else { return }
                await model.listen()
            }
        }
    }
}
  
#Preview {
    WatchlistView()
}
