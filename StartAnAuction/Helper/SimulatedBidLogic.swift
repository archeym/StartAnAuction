//
//  SimulatedBidLogic.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

///Abstraction for an incoming stream of external bid
protocol BidFeed: AnyObject {
    ///   - auctionId: unique id for the current auction
    ///   - priceProvider: async closure that returns the latest current price (Decimal)
    ///   - remainingSecondsProvider: async closure that returns remaining seconds in the auction
    func start(
        auctionId: UUID,
        priceProvider: @escaping @Sendable () async -> Decimal,
        remainingSecondsProvider: @escaping @Sendable () async -> Int
    ) -> AsyncStream<Bid>

    func stop()

    ///Notify an accepted bid just happened,  players will respect a cooldown
    func notifyAcceptedBid(cooldown seconds: Double)
}


final class SimulatedBidFeed: BidFeed {
    
    struct Config: Sendable {

        var playersNames: [String] = [
            "LeBron James", "Stephen Curry", "Kevin Durant", "Giannis Antetokounmpo", "Nikola Jokic",
            "Luka Doncic", "Kawhi Leonard", "Jayson Tatum", "Jimmy Butler", "Anthony Davis"
        ]

        var minPlayers: Int = 3
        var maxPlayers: Int = 6

        ///Regular Players timing (seconds)
        var regularDelayRange: ClosedRange<Double> = 0.6...2.2

        ///Regular Players increment logic
        ///Percentage bump relative to current price (e.g. 0.01...0.08 = +1% to +8%)
        var percentIncrementRange: ClosedRange<Double> = 0.01...0.08
        /// Absolute minimum increment to ensure visible movement (currency units)
        var minimumAbsoluteStep: Decimal = 1
        var playersDelayRange: ClosedRange<Double> = 2.5...5.0

        ///Rounding for displayed amounts
        var roundingScale: Int = 2

        ///If true, player reduce their delay as the auction nears the end.
        var enableAccelerationNearEnd: Bool = true
        /// Optional global cooldown (seconds) applied after any accepted bid.
        var defaultCooldownSecondsAfterAcceptedBid: Double = 0 // e.g. 1.5 to slow the feed slightly
    }

    private var isRunning = false
    private var tasks = [Task<Void, Never>]()
    private let config: Config

    // Cooldown gate - players won’t bid before this time after an accepted bid
    private var nextAllowedDate = Date.distantPast

    init(config: Config = .init()) {
        self.config = config
    }

    func start(
        auctionId: UUID,
        priceProvider: @escaping @Sendable () async -> Decimal,
        remainingSecondsProvider: @escaping @Sendable () async -> Int
    ) -> AsyncStream<Bid> {
        isRunning = true
        let (stream, continuation) = AsyncStream.makeStream(of: Bid.self)

        let playersCount = max(config.minPlayers, Int.random(in: config.minPlayers...max(config.minPlayers, config.maxPlayers)))
        
        for player in 0..<playersCount {
            let name = config.playersNames[player % max(1, config.playersNames.count)]
            let task = Task { [weak self] in
                guard let self = self else { return }
                while self.isRunning {
                    let delay = await self.computeDelay(
                        base: self.config.regularDelayRange,
                        remainingSecondsProvider: remainingSecondsProvider )
                    
                    try? await Task.sleep(nanoseconds: delay)
                    if !self.isRunning { break }

                    let basePrice = await priceProvider()//call with await to get the current price

                    // Compute increment
                    let percent = Double.random(in: self.config.percentIncrementRange)
                    let incDouble = max(percent * basePrice.doubleValue, self.config.minimumAbsoluteStep.doubleValue)
                    let amount = (basePrice + Decimal(incDouble)).rounded(scale: self.config.roundingScale)

                    continuation.yield(Bid(bidderName: name, amount: amount, timestamp: Date()))
                }
            }
            tasks.append(task)
        }

        continuation.onTermination = { [weak self] _ in
            self?.stop()
        }

        return stream
    }

    func stop() {
        isRunning = false
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        nextAllowedDate = .distantPast
    }

    func notifyAcceptedBid(cooldown seconds: Double) {
        guard seconds > 0 else { return }
        let candidate = Date().addingTimeInterval(seconds)
        // Use the max to avoid shortening an existing longer cooldown
        if candidate > nextAllowedDate { nextAllowedDate = candidate }
    }

    ///Computes sleep nanosecond for   global cooldown
    private func computeDelay(
        base: ClosedRange<Double>,
        remainingSecondsProvider: @escaping @Sendable () async -> Int
    ) async -> UInt64 {
        var chosen: Double
        if config.enableAccelerationNearEnd {
            let remaining = await remainingSecondsProvider()
            switch remaining {
            case 0...5:
                chosen = Double.random(in: 1.9...2.1)
            case 6...10:
                chosen = Double.random(in: 2.5...2.9)
            case 11...20:
                chosen = Double.random(in: 3.1...4.9)
            case 21...40:
                chosen = Double.random(in: 4.1...5.9)
            default:
                chosen = Double.random(in: base)
            }
        } else {
            chosen = Double.random(in: base)
        }

        // global cooldown
        let wake = max(Date().addingTimeInterval(chosen), nextAllowedDate)
        let ns = max(0, wake.timeIntervalSinceNow) * 1_000_000_000
        return UInt64(ns)
    }
}
