//
//  StartAnAuctionTests.swift
//  StartAnAuctionTests
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//


import XCTest
import Combine
@testable import StartAnAuction

@MainActor
final class AuctionViewModelTests: XCTestCase {

    // Build a fresh VM + fake per test
    private func makeVM(fetcher: FakeMerchantFetcher = FakeMerchantFetcher())
    -> (AuctionViewModel, FakeMerchantFetcher) {
        let vm = AuctionViewModel(
            manager: AuctionManager(),
            bidFeed: SimulatedBidFeed(),
            config: .init(startingPrice: 0, durationSeconds: 15),
            merchantFetcher: fetcher
        )
        return (vm, fetcher)
    }

    func test_canStartAuction_EmptyName_False() {
        let (vm, _) = makeVM()
        vm.userName = ""
        XCTAssertFalse(vm.canStartAuction)
    }

    func test_canStartAuction_NonEmptyName_True() {
        let (vm, _) = makeVM()
        vm.userName = "Archie"
        XCTAssertTrue(vm.canStartAuction)
    }

    func test_loadMerchants_updatesPublishedMerchants_async() async {
        let (vm, fetcher) = makeVM()

        XCTAssertEqual(vm.merchants.count, 0, "Initially empty")

        // Act: trigger load; VM should flip loading to true
        vm.loadMerchants()
        XCTAssertTrue(vm.isLoading)
        XCTAssertEqual(fetcher.fetchCallCount, 1)

        // Simulate a successful response from the service
        fetcher.pushMerchants([
            Merchant(id: 1, name: "Merchant A"),
            Merchant(id: 2, name: "Merchant B")
        ])

        // Await the first time isLoading becomes false (emission after the VM receives merchants)
        _ = await vm.$isLoading.values.first(where: { $0 == false })

        // Assert
        XCTAssertEqual(vm.merchants.compactMap(\.name), ["Merchant A", "Merchant B"])
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Merchants error flow (async/await)

    func test_loadMerchants_setsErrorMessage_onError_async() async {
        let (vm, fetcher) = makeVM()

        vm.loadMerchants()
        XCTAssertTrue(vm.isLoading)

        // Simulate an error from the pipeline
        fetcher.pushError(.decodingFailed(description: "typeMismatch(Int, …)"))

        // Wait until the VM reports isLoading == false (it happens in the error sink)
        _ = await vm.$isLoading.values.first(where: { $0 == false })

        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("Failed to decode") == true, "Expected a decoding error message")
    }
}

final class FakeMerchantFetcher: MerchantProtocol {
    var merchantsPublisher: AnyPublisher<[Merchant], Never> {
        merchantsSubject.eraseToAnyPublisher()
    }
    var errorsPublisher: AnyPublisher<APIError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    private let merchantsSubject = CurrentValueSubject<[Merchant], Never>([])
    private let errorsSubject = PassthroughSubject<APIError, Never>()

    private(set) var fetchCallCount = 0

    func fetchMerchants() {
        fetchCallCount += 1
    }

    // Helpers to simulate API results
    func pushMerchants(_ merchants: [Merchant]) {
        merchantsSubject.send(merchants)
    }
    func pushError(_ error: APIError) {
        errorsSubject.send(error)
    }
}
