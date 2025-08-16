//
//  AuctionManager.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

actor AuctionManager {
    
    private var auctionId: UUID?
    private var isActive = false
    private var startDate: Date?
    private var endDate: Date?
    private var currentPrice: Decimal = 0
    private var currentWinner: String?

    
    /// Starts a brand new auction and returns a snapshot of the state
    func startNewAuction(durationSeconds: Int, startingPrice: Decimal, now: Date = .init()) -> AuctionSnapshot {
        auctionId = UUID()
        isActive = true
        startDate = now
        endDate = now.addingTimeInterval(TimeInterval(durationSeconds))
        currentPrice = startingPrice
        currentWinner = nil
        return snapshot()
    }

    func stopAuction() {
        isActive = false
    }

    func timeRemaining(now: Date = .init()) -> TimeInterval {
        guard let end = endDate, isActive else { return 0 }
        return max(0, end.timeIntervalSince(now))
    }

    func canAcceptBids(now: Date = .init()) -> Bool {
        guard isActive, let end = endDate else { return false }
        return now < end
    }

    /// Returns true if the bid was accepted, greater than current price and before the auction end
    @discardableResult
    func placeBid(_ bid: Bid, now: Date = .init()) -> Bool {
        guard canAcceptBids(now: now) else { return false }
        if bid.amount ?? 0 > currentPrice {
            currentPrice = bid.amount ?? 0
            currentWinner = bid.bidderName
            return true
        }
        return false
    }

    func snapshot() -> AuctionSnapshot {
        
        AuctionSnapshot(
            auctionId: auctionId,
            isActive: isActive,
            startDate: startDate,
            endDate: endDate,
            currentPrice: currentPrice,
            currentWinner: currentWinner
        )
        
    }
}
