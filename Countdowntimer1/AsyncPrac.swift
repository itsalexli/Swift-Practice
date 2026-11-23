////
////  AsyncPrac.swift
////  Countdowntimer1
////
////  Created by Alexander Li on 2026-11-20.
////
//
//import SwiftUI
//
////import Foundation
////
////let mockPrices: [String: Double] = ["HOOD": 42, "AAPL": 228, "NVDA": 141, "TSLA": 352, "MSFT": 415]
////
////enum MockError: Error {
////    case unknownTicker
////    case networkDown
////}
////
////func fetchPrice(ticker: String) async throws -> Double {
////    try await Task.sleep(for: .milliseconds(Int.random(in: 200...1000)))
////    guard let price = mockPrices[ticker] else { throw MockError.unknownTicker }
////    return price
////}
////
////func check(name: String, condition: Bool) {
////    print(condition ? "✅ PASS" : "❌ FAIL", name)
////}
////
////func doubleAllinOrder(numbers: [Int]) async -> [Int] {
////    return await withTaskGroup(of: [Int].self) { group in
////        for (index, n) in numbers.enumerated() {
////            group.addTask {return (index, n * 2)}
////        }
////        
////        var results = [Int](repeating: 0, count: nu zmbers.count)
////    }
////}
////
////
////
////func totalInParallel(tickers: [String]) async -> Double {
////    return await withTaskGroup(of: Double.self) { group in
////        for ticker in tickers {
////            group.addTask {
////                if let price = try? await fetchPrice(ticker: ticker) {
////                    return price
////                }
////                return 0
////            }
////        }
////        var total = 0.0
////        for await num in group {
////            total += num
////        }
////        return total
////    }
////}
////
////func countAvailble(tickers: [String]) async -> Int {
////    return await withTaskGroup(of: Int.self) { group in
////        for ticker in tickers {
////            group.addTask {
////                if let price = try? await fetchPrice(ticker: ticker) {
////                    return price
////                }
////                return 0
////            }
////        }
////
////        var count = 0
////        for await good in group {
////            if good {count += 1}
////        }
////        return count
////    }
////}
////
////
////func retryAttempts(
//
//
//
//final class FlakyServer {
//    private var failuresLeft: Int
//    private(set) var attempts = 0
//
//    init(failFirst: Int) {
//        failuresLeft = failFirst
//    }
//
//    func submit(orderID: Int) async throws {
//        attempts += 1
//        try await Task.sleep(for: .milliseconds(100))
//        if failuresLeft > 0 {
//            failuresLeft -= 1
//
//        }
//    }
//}
//
//func submitWithRetry(orderID: Int, server: FlakyServer, maxAttempts: Int) async -> Bool{
//    for attempt in 1...maxAttempts {
//        if (try? await server.submit(orderID:orderID)) != nil {
//            return true
//        }
//        if attempt < maxAttempts {
//            try? await Task.sleep(for: .seconds(1))
//        }
//    }
//    return false
//}
//
