//
//  Mock2.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-25.
//

import SwiftUI
import Foundation

struct StockQuote: Identifiable, Equatable, Sendable {
    let id: String // Ticker symbol, e.g. "HOOD"
    let name: String
    let price: Double
    let openPrice: Double
    let timestamp: Date
}

enum ServiceError: Error, Sendable {
    case networkFailure
    case rateLimited
}

final class MockMarketService: Sendable {
    static let shared = MockMarketService()

    private let baseStocks: [(id: String, name: String, open: Double)] = [
        ("HOOD", "Robinhood", 24.50),
        ("AAPL", "Apple Inc.", 225.00),
        ("NVDA", "NVIDIA Corp.", 135.20),
        ("TSLA", "Tesla, Inc.", 250.00),
        ("AMZN", "Amazon", 186.40),
        ("GOOG", "Alphabet Inc.", 168.75),
        ("META", "Meta", 580.10),
        ("MSFT", "Microsoft.", 420.30)
    ]

    /// Fetches latest quotes. Completion fires on a background queue (0.2s–1.8s latency, ~20% failure rate).
    func fetchQuotes(completion: @escaping @Sendable (Result<[StockQuote], ServiceError>) -> Void) {
        let delay = Double.random(in: 0.2...1.8)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if Int.random(in: 1...5) == 1 {
                completion(.failure(.networkFailure))
                return
            }
            let now = Date()
            let quotes = self.baseStocks.map { stock in
                let delta = Double.random(in: -0.05...0.05)
                let price = (stock.open * (1 + delta) * 100).rounded() / 100
                return StockQuote(
                    id: stock.id,
                    name: stock.name,
                    price: price,
                    openPrice: stock.open,
                    timestamp: now
                )
            }
            completion(.success(quotes))
        }
    }

    /// Submits a buy order. Completion fires on a background queue (0.5s–2.0s latency, ~30% failure rate).
    func submitBuyOrder(ticker: String, completion: @escaping @Sendable (Result<Void, ServiceError>) -> Void) {
        let delay = Double.random(in: 0.5...2.0)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            let succeeded = Int.random(in: 1...10) > 3
            completion(succeeded ? .success(()) : .failure(.networkFailure))
        }
    }
}


//"Today we're going to build a single-page Stock Watchlist app in SwiftUI.
//The screen should show a list of stocks with their ticker symbol, company name, current price, and percent change from the open price—styled green when up and red when down. Prices should refresh automatically every couple of seconds from the provided MockMarketService, and the user should also be able to manually refresh or pause live updates.
//Next to each stock, add a quick Buy button that submits an order using the service. The user should be able to see what's happening with their order—whether it's submitting, filled, or failed—and retry if it fails.
//Since network calls are slow and unreliable, make sure the app behaves cleanly when the user backgrounds the app, taps buttons repeatedly, or hits network failures."


struct StockView: View {
    
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    @State private var sm = StockModel()
    
    @State private var isPaused = false
    
    private var isRunning: Bool {
        return !isPaused && scenePhase == .active
    }
    
    var body: some View {
        VStack {
            if sm.showError {
                    Text("Error with loading")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(.red)
                }
            List {
                ForEach(sm.quotes) { quote in
                    StockRow(
                        stock: quote,
                        orderStatus: sm.orderStatuses[quote.id] ?? .idle,
                        onBuy: {sm.buyStock(ticker: quote.id)}
                    )
                }
            }
            .listStyle(.plain)
            .animation(.default, value: sm.quotes)
            HStack {
                Button(!isPaused ? "Pause" : "Resume") {
                    isPaused.toggle()
                }
                .buttonStyle(.borderedProminent)
                Button("Refresh") {
                    sm.updateStocks()
                        
                }
                .buttonStyle(.borderedProminent)
                .disabled(sm.isLoading)
            }
        }
        .task (id: isRunning) {
            guard isRunning else {return}
            while !Task.isCancelled {
                sm.updateStocks()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }
}

struct StockRow: View {
    let stock: StockQuote
    let orderStatus: OrderStatus
    let onBuy: () -> Void
    var percentChange: Double {
        (stock.price - stock.openPrice) / stock.openPrice
    }
    

    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.id).font(.headline)
                Text(stock.name).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(stock.price, format: .currency(code: "USD"))
                    .font(.headline.monospacedDigit())
                    .frame(minWidth: 90, alignment: .trailing)

                Text(percentChange, format: .percent.precision(.fractionLength(2)).sign(strategy: .always()))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(percentChange >= 0 ? .green : .red)
                    .frame(minWidth: 70, alignment: .trailing)
            }

            Button {
                onBuy()
            } label: {
                switch orderStatus {
                    case .idle:
                        Text("Buy")
                    case .submitting:
                        ProgressView()
                            .controlSize(.small)
                    case .filled:
                        Text("Filled")
                    case .failed:
                        Text("Retry")
                    }
                
            }
            .frame(minWidth: 56)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .padding(.leading)
            .disabled(orderStatus == .submitting)
            .tint(orderStatus == .filled ? .green : orderStatus == .failed ? .red : .accentColor)
            
        }
    }
}

enum OrderStatus: Equatable {
    case idle
    case submitting
    case filled
    case failed
}

@Observable
@MainActor
final class StockModel {
    

    private(set) var showError: Bool = false
    private(set) var orderStatuses: [String: OrderStatus] = [:]
    private let service: MockMarketService
    private(set) var quotes: [StockQuote] = []
    private(set) var isLoading = false
    
    init(service: MockMarketService = .shared) {
        self.service = service
    }
    
    func updateStocks() {
        guard !isLoading else { return }
        isLoading = true
        service.fetchQuotes { [weak self] result in
            Task { @MainActor in
                guard let self else {return}
                self.isLoading = false
                switch result {
                case .success(let newQuotes):
                    self.quotes = newQuotes
                    self.showError = false
                case .failure(let error):
                    self.showError = true
                    print(error)
                    }
                }
            }
            
        }

    
    func buyStock(ticker: String) {
        guard orderStatuses[ticker] != .submitting else {return}
        orderStatuses[ticker] = .submitting
        
        service.submitBuyOrder(ticker: ticker) { [weak self] result in
            Task { @MainActor in
                guard let self else {return}
                switch result {
                case.success:
                    self.orderStatuses[ticker] = .filled
                case .failure:
                    self.orderStatuses[ticker] = .failed
                }
            }
        }
    }
}


#Preview{
    StockView()
}





