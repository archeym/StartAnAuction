//
//  DecimalTextFieldCoordinator.swift
//  CashManagementApp
//
//  Created by Arkadijs Makarenko on 29/01/2024.
//

import SwiftUI
import UIKit

class DecimalTextFieldCoordinator: NSObject, UITextFieldDelegate {
    @Binding var text: String
    var textField: UITextField?

    var onEditingChanged: (Bool) -> Void
    private var rawDigits: String = ""

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

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEditingChanged(false)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric input or backspace
        if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && string != "" {
            return false
        }

        if string == "" {
            if !rawDigits.isEmpty {
                rawDigits.removeLast()
            }
        } else {
            rawDigits.append(string)
        }

        let doubleValue = (Double(rawDigits) ?? 0) / 100.0

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_IE") // Change as needed

        let formatted = formatter.string(from: NSNumber(value: doubleValue)) ?? "€0.00"

        text = formatted
        textField.text = formatted

        // Keep cursor at end
        let endPosition = textField.endOfDocument
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
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

    func makeCoordinator() -> DecimalTextFieldCoordinator {
        DecimalTextFieldCoordinator(text: $text, onEditingChanged: onEditingChanged)
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


class CharacterTextFieldCoordinator: NSObject, UITextFieldDelegate {
    
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
