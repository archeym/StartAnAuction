//
//  ScrollDismissModifier.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

struct ScrollDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
    }
}

struct DecimalStyleTextFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16).weight(.black))
            .keyboardType(.decimalPad)
    }
}

struct TextFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 55)
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(12)
    }
}

struct ForTextFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: UIDevice.isIPad ? 15 : 14))
            .foregroundColor(.secondary)
            .offset(y: -10)
    }
}

struct ForNamePhoneTextFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18).weight(.black))
            .keyboardType(.namePhonePad)
            .multilineTextAlignment(.trailing)
            .autocorrectionDisabled()
    }
}
