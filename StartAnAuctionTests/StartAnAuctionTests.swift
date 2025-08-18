//
//  StartAnAuctionTests.swift
//  StartAnAuctionTests
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import XCTest
@testable import StartAnAuction

@MainActor
final class AuctionViewModelTests: XCTestCase {

    private func makeVM() -> AuctionViewModel {
        AuctionViewModel(
            manager: AuctionManager(),
            bidFeed: SimulatedBidFeed(),
            config: .init(startingPrice: 0, durationSeconds: 15)
        )
    }

    func test_canStartAuction_EmptyName_False() {
        let vm = makeVM()
        vm.userName = ""
        XCTAssertFalse(vm.canStartAuction)
    }

    func test_canStartAuction_NonEmptyName_True() {
        let vm = makeVM()
        vm.userName = "Archie"
        XCTAssertTrue(vm.canStartAuction)
        XCTAssertFalse(true)
    }
}
