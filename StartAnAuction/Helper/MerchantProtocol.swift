//
//  MerchantProtocol.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 21/08/2025.
//

import Foundation
import Combine

protocol MerchantProtocol {
    
    var merchantsPublisher: AnyPublisher<[Merchant], Never> { get }
    var errorsPublisher: AnyPublisher<APIError, Never> { get }

    func fetchMerchants()
}

final class MerchantFetcher: MerchantProtocol {

    private let service: any MerchantServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private let merchantsSubject = CurrentValueSubject<[Merchant], Never>([])
    private let errorsSubject = PassthroughSubject<APIError, Never>()

    var merchantsPublisher: AnyPublisher<[Merchant], Never> {
        merchantsSubject.eraseToAnyPublisher()
    }
    
    var errorsPublisher: AnyPublisher<APIError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    init(service: any MerchantServiceProtocol) {
        self.service = service
    }

    func fetchMerchants() {
        service.fetchMerchants()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorsSubject.send(error) // typed APIError
                    }
                },
                receiveValue: { [weak self] merchants in
                    self?.merchantsSubject.send(merchants)
                }
            )
            .store(in: &cancellables)
    }
}
