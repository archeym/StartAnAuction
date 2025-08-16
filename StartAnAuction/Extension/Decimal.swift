//
//  Decimal.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}

extension Decimal {
    var doubleValue: Double { (self as NSDecimalNumber).doubleValue }
}

extension Double {
    var asDecimal: Decimal { Decimal(self) }
    var asNSDecimalNumber: NSDecimalNumber { NSDecimalNumber(value: self) }
}


enum DecimalParser {
    static func parse(_ text: String, locale: Locale = .current) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let dec = NumberFormatter()
        dec.numberStyle = .decimal
        dec.locale = locale
        if let n = dec.number(from: trimmed) { return n.decimalValue }

        let cur = NumberFormatter()
        cur.numberStyle = .currency
        cur.locale = locale
        if let n = cur.number(from: trimmed) { return n.decimalValue }

        let currencySymbol = cur.currencySymbol ?? ""
        let grouping = dec.groupingSeparator ?? ","
        let decimalSep = dec.decimalSeparator ?? "."

        var cleaned = trimmed
            .replacingOccurrences(of: currencySymbol, with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: grouping, with: "")

        if decimalSep != "." {
            cleaned = cleaned.replacingOccurrences(of: decimalSep, with: ".")
        }

        // Keep digits, one dot, and optional leading minus
        //In auctions you probably don’t need minus, but this is safe
        let allowed = Set("0123456789.-")
        cleaned = String(cleaned.filter { allowed.contains($0) })

        return Decimal(string: cleaned)
    }
}

enum TimeFormatter {
    static func mmss(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    static func mmssSS(milliseconds: Int) -> String {
        let totalSeconds = milliseconds / 1000
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        let hundredths = (milliseconds % 1000) / 10
        return String(format: "%02d:%02d.%02d", m, s, hundredths)
    }
}
