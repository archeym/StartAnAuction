//
//  Bid.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import Foundation

struct Bid: Identifiable, Sendable {
    
    let id = UUID()
    let bidderName: String?
    let amount: Decimal?
    let timestamp: Date?
    
}

struct AuctionSnapshot: Sendable {
    
    let auctionId: UUID?
    let isActive: Bool?
    let startDate: Date?
    let endDate: Date?
    let currentPrice: Decimal?
    let currentWinner: String?
    
}
