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
    static func parse(_ text: String) -> Decimal? {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = .current
        if let n = nf.number(from: text) { return n.decimalValue }
        let canonical = text.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: canonical)
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
