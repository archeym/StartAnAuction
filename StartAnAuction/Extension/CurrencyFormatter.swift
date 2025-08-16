//
//  CurrencyFormatter.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

final class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    private let formatter: NumberFormatter

    private init() {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = .current
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        self.formatter = nf
    }

    func string(from decimal: Decimal) -> String {
        formatter.string(from: decimal as NSDecimalNumber) ?? "—"
    }
}
