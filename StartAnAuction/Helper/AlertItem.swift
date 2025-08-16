//
//  AlertItem.swift
//  CashManagementApp
//
//  Created by Arkadijs Makarenko on 18/08/2023.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    let title: String
    let message: String
    let button1Title: String
    var button2Title: String? = nil
    var colorButton1: Color? = .black
    var colorButton2: Color? = .accentColor
    var bigIconName: String? = nil
    var smallIconName: String? = nil
    let action1: (() -> Void)
    var action2: (() -> Void)? = nil
}

struct AlertItemWithOK: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text?
    var dismissButton: Alert.Button?
}
