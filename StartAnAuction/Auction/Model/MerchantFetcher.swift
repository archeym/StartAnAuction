//
//  MerchantFetcher.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 21/08/2025.
//

import Foundation

struct Merchant: Decodable, Identifiable, Equatable {
    let id: Int?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let coding = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? coding.decode(Int.self, forKey: .id) {
            self.id = intId
        } else {
            self.id = try coding.decode(Int.self, forKey: .id)
        }
        self.name = try coding.decode(String.self, forKey: .name)
    }
}
