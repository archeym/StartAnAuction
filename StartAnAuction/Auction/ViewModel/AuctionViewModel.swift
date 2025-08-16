//
//  AuctionViewModel.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

@MainActor
final class AuctionViewModel: ObservableObject {
    
    struct Config {
        let startingPrice: Decimal
        let durationSeconds: Int
    }

    @Published var userName: String = ""
    @Published var bidInput: String = ""
    @Published var errorText: String? = nil
    
    @Published var currentPriceText: String = "—"
    @Published var currentWinnerText: String = "No winner yet"
    @Published var remainingText: String = "00:00"
    @Published var isRunning: Bool = false
    @Published var endDate: Date?

    private let manager: AuctionManager
    private let bidFeed: BidFeed
    private let config: Config
    private(set) var cachedPrice: Decimal = 0
    
    private var feedTask: Task<Void, Never>?
    private var clockTask: Task<Void, Never>?

    init(manager: AuctionManager, bidFeed: BidFeed, config: Config) {
        self.manager = manager
        self.bidFeed = bidFeed
        self.config = config
        Task { await refreshFromManager() }
    }
    
    var canSubmit: Bool {
        isRunning && !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        DecimalParser.parse(bidInput) != nil
    }

    var isAmountHigher: Bool {
        guard let amt = DecimalParser.parse(bidInput) else { return false }
        return amt > cachedPrice
    }

    func startAuction() {
        feedTask?.cancel(); feedTask = nil
        clockTask?.cancel(); clockTask = nil
        bidFeed.stop()

        Task {
            _ = await manager.startNewAuction(
                durationSeconds: config.durationSeconds,
                startingPrice: config.startingPrice
            )
            await refreshFromManager()
            isRunning = true

            clockTask = Task { [weak self] in
                guard let self = self else { return }
                while await self.manager.canAcceptBids() {
                    await self.refreshFromManager()
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
                await self.refreshFromManager()
                self.isRunning = false
                self.bidFeed.stop()
            }
            
            

            let snapshot = await manager.snapshot()
            guard let auctionId = snapshot.auctionId else { return }

            let stream = bidFeed.start(
                auctionId: auctionId,
                priceProvider: { [weak self] in
                    guard let self = self else { return 0 }
                    let snap = await self.manager.snapshot()
                    return snap.currentPrice ?? 0
                },
                remainingSecondsProvider: { [weak self] in
                    guard let self = self else { return 0 }
                    let seconds = Int(await self.manager.timeRemaining())
                    return max(0, seconds)
                }
            )

            feedTask = Task { [weak self] in
                guard let self = self else { return }
                for await bid in stream {
                    _ = await self.manager.placeBid(bid)
                    await self.refreshFromManager()
                }
            }
        }
    }

    func placeUserBid() {
        errorText = nil
        guard isRunning else {
            errorText = "Start a new auction first."
            return
        }
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorText = "Enter your name."
            return
        }
        guard let amount = DecimalParser.parse(bidInput) else {
            errorText = "Enter a valid amount."
            return
        }
        guard amount > cachedPrice else {
            errorText = "Your bid must be higher than the current price."
            return
        }

        Task {
            let accepted = await manager.placeBid(
                Bid(bidderName: name, amount: amount.rounded(scale: 2), timestamp: Date())
            )
            if accepted { bidInput = "" } else {
                errorText = "Bid rejected (probably too low or auction ended)."
            }
            await refreshFromManager()
        }
    }

    private func refreshFromManager() async {
        let snap = await manager.snapshot()

        // existing updates...
        currentPriceText = CurrencyFormatter.shared.string(from: snap.currentPrice ?? 0)
        currentWinnerText = snap.currentWinner.map { "Current winner: \($0)" } ?? "No winner yet"

        // publish endDate to the view
        endDate = snap.endDate

        // keep legacy string too if you still show it elsewhere
        if let end = snap.endDate {
            let ms = max(0, Int(end.timeIntervalSince(Date()) * 1000))
            remainingText = TimeFormatter.mmssSS(milliseconds: ms)
        } else {
            remainingText = TimeFormatter.mmssSS(milliseconds: 0)
        }

        isRunning = snap.isActive ?? false && (snap.endDate ?? Date()) > Date()
    }
    
    func computeRemainingMilliseconds(now: Date, endDate: Date?) -> Int {
        guard let end = endDate else { return 0 }
        return max(0, Int(end.timeIntervalSince(now) * 1000))
    }
    
}

