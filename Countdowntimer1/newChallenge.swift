//
//  newChallenge.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    // Simulates sending order request to RH backend
    func sendOrder(order: Order, success: @escaping () -> Void, failure: @escaping () -> Void) {
        print("sendingOrder: \(order.identifier)")
        let requestDuration = Double.random(in: 0...1.0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + requestDuration) {
            let rand = Int.random(in: 0...1)
            if rand == 0 {
                print("success: \(order.identifier)")
                success()
            } else {
                print("failure: \(order.identifier)")
                failure()
            }
        }
    }
}

public struct Order: Equatable { let identifier: String }

/* Do not edit above this line */

public class OrderManager {
    /// **Do not change this method signature**
    var queue: [Order] = []
    var isSending = false
    var attempts = 0
    
    private func sendNext() {
        guard let currentOrder = queue.first else {
            isSending = false
            return
        }
        
        isSending = true
        NetworkManager.shared.sendOrder(
                    order: currentOrder,
                    success: { [weak self] in
                        guard let self else { return }
                        self.attempts = 0
                        self.queue.removeFirst()
                        self.sendNext()
                    },
                    failure: { [weak self] in
                        guard let self else { return }
                        self.attempts += 1
                        if self.attempts < 3 {
                            self.sendNext()
                        } else {
                            self.attempts = 0
                            self.queue.removeFirst()
                            self.sendNext()
                        }
                    }
            )
    }
    
    public func placeOrder(_ order: Order) {
        queue.append(order)
        if !isSending {
            sendNext()
        }
    }
}
