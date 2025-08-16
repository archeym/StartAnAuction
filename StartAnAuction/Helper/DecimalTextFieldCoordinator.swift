//
//  DecimalTextFieldCoordinator.swift
//  CashManagementApp
//
//  Created by Arkadijs Makarenko on 29/01/2024.
//

import SwiftUI
import UIKit

final class DecimalTextFieldCoordinator: NSObject, UITextFieldDelegate {
    @Binding var text: String
    var textField: UITextField?
    var onEditingChanged: (Bool) -> Void
    private let locale: Locale
    private let maxFractionDigits: Int

    init(text: Binding<String>, onEditingChanged: @escaping (Bool) -> Void, locale: Locale, maxFractionDigits: Int) {
        _text = text
        self.onEditingChanged = onEditingChanged
        self.locale = locale
        self.maxFractionDigits = maxFractionDigits
    }

    @objc func doneButtonTapped() {
        textField?.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        textField.inputAccessoryView = toolbar
        self.textField = textField
        onEditingChanged(true)

        if text.trimmingCharacters(in: .whitespacesAndNewlines) == "0.00" || text == "0,00" {
            text = ""
            textField.text = ""
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEditingChanged(false)
        if text.isEmpty {
            text = "0.00"
            textField.text = "0.00"
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let sep = locale.decimalSeparator ?? "."
        let incoming = (string == "." || string == ",") ? sep : string
        guard let r = Range(range, in: textField.text ?? "") else { return false }
        var proposed = (textField.text ?? "").replacingCharacters(in: r, with: incoming)

        // only digits and one separator
        let allowedChars = Set("0123456789\(sep)")
        proposed = String(proposed.filter { allowedChars.contains($0) })
        if proposed.components(separatedBy: sep).count > 2 { return false }

        // enforce max fraction digits
        if let srange = proposed.range(of: sep) {
            let fractional = proposed[srange.upperBound...]
            if fractional.count > maxFractionDigits { return false }
        }

        text = proposed
        textField.text = proposed

        // cursor stays at end
        let end = textField.endOfDocument
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: end, to: end)
        }
        return false
    }
}

struct DecimalCurrencyTextField: UIViewRepresentable {
    var placeholder: String
    var textAlignment: NSTextAlignment = .left
    var keyboardType: UIKeyboardType = .numberPad
    var shouldOpenKeyboard: Bool = false
    @Binding var text: String
    var onEditingChanged: (Bool) -> Void

    // 🔑 add these to pass locale + fraction limit
    var locale: Locale = .current
    var maxFractionDigits: Int = 2

    func makeCoordinator() -> DecimalTextFieldCoordinator {
        DecimalTextFieldCoordinator(
            text: $text,
            onEditingChanged: onEditingChanged,
            locale: locale,
            maxFractionDigits: maxFractionDigits
        )
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.textAlignment = textAlignment
        textField.text = text
        if shouldOpenKeyboard {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
        }
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}


final class CharacterTextFieldCoordinator: NSObject, UITextFieldDelegate {
    
    @Binding var text: String
    var textField: UITextField?
    
    var onEditingChanged: (Bool) -> Void
    
    init(text: Binding<String>, onEditingChanged: @escaping (Bool) -> Void) {
        _text = text
        self.onEditingChanged = onEditingChanged
    }
    
    @objc func doneButtonTapped() {
        textField?.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        
        textField.inputAccessoryView = toolbar
        self.textField = textField
        
        onEditingChanged(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow all characters, including letters, numbers, and special characters
        
        // Update the text binding
        if let currentText = textField.text as NSString? {
            let newText = currentText.replacingCharacters(in: range, with: string)
            text = newText
        }
        
        return false
    }
}

struct CharacterTextField: UIViewRepresentable {
    
    var placeholder: String
    var textAlignmentCenter: NSTextAlignment
    var keyboardType: UIKeyboardType
    var shouldOpenKeyboard: Bool = false
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    
    func makeCoordinator() -> CharacterTextFieldCoordinator {
        return CharacterTextFieldCoordinator(text: $text, onEditingChanged: onEditingChanged)
    }
    
    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.textAlignment = textAlignmentCenter
        // Disable auto features
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no
        
        if shouldOpenKeyboard {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
}
