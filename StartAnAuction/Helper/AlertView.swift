//
//  AlertView.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 16/08/2025.
//

import SwiftUI

struct AlertView: ViewModifier {
    
    @Binding var isVisible: Bool
    let title: String
    let message: String
    let button1Title: String
    let button2Title: String?
    let colorButton1: Color
    let colorButton2: Color?
    let bigIconName: String?
    let smallIconName: String?
    let action1: (() -> Void)
    let action2: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isVisible {
                Color.black.opacity(0.2)
                    .overlay(
                        VStack(spacing: 0) {
                            VStack(spacing: UIDevice.isIPhone ? 20 : 25) {
                                if let bigIconName = bigIconName {
                                    Image(bigIconName)
                                }
                                
                                HStack(alignment: .top, spacing: 5) {
                                    if let smallIconName = smallIconName {
                                        Image(smallIconName)
                                    }
                                    
                                    Text(title)
                                        .font(.title2)
                                        .bold()
                                }
                                
                                Text(message)
                                    .font(.system(size: 18).weight(.semibold))
                                   
                            }
                            .multilineTextAlignment(.center)
                            .padding(UIDevice.isIPhone ? 20 : 25)
                            
                            Line(color: .secondary.opacity(0.5), size: 0.5).padding(.horizontal, -40)
                            HStack(spacing: 0) {
                                Text(button1Title)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .background(button2Title == nil ? .accentColor : colorButton1)
                                    .foregroundColor(button2Title == nil ? .white : .black)
                                    .onTapGesture {
                                        close()
                                        action1()
                                    }
                                
                                if let buttonTitle = button2Title, let action = action2 {
                                    Text(buttonTitle)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .background(colorButton2)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            close()
                                            action()
                                        }
                                }
                            }.frame(height: UIDevice.isIPhone ? 50 : 55)
                        }
                        .frame(width:  UIDevice.isIPhone ? screenSize.width / 1.2 : screenSize.width / 1.8)
                        .background(Color.white)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                            .shadow(color: .secondary.opacity(0.1), radius: 1, x: 0, y: 1))
                    ).ignoresSafeArea(.all)
            }
        }
    }
    
    private func close() {
        isVisible = false
    }
}


extension View {
    
    func alertWith(isVisible: Binding<Bool>,
                   title: String,
                   message: String,
                   button1Title: String,
                   button2Title: String? = nil,
                   colorButton1: Color = .white,
                   colorButton2: Color? = .accentColor.opacity(0.85),
                   bigIconName: String? = nil,
                   smallIconName: String? = nil,
                   action1: @escaping (() -> Void),
                   action2: (() -> Void)? = nil) -> some View {
        self.modifier(AlertView(isVisible: isVisible,
                                title: title,
                                message: message,
                                button1Title: button1Title,
                                button2Title: button2Title,
                                colorButton1: colorButton1,
                                colorButton2: colorButton2,
                                bigIconName: bigIconName,
                                smallIconName: smallIconName,
                                action1: action1,
                                action2: action2))
    }
    
    /// Default alert with title, subtitle and one button.
    func alertWith(isVisible: Binding<Bool>,
                   title: String,
                   message: String,
                   buttonTitle: String,
                   colorButton1: Color = .white,
                   action: @escaping (() -> Void)) -> some View {
        self.modifier(AlertView(isVisible: isVisible,
                                title: title,
                                message: message,
                                button1Title: buttonTitle,
                                button2Title: nil,
                                colorButton1: colorButton1,
                                colorButton2: nil,
                                bigIconName: nil,
                                smallIconName: nil,
                                action1: action,
                                action2: nil))
    }
    
    func alertWith(_ alertItem: Binding<AlertItem?>) -> some View {
        self.modifier(SimpleAlertView(alertItem: alertItem))
    }
    
}

struct SimpleAlertView: ViewModifier {
    
    @Binding var alertItem: AlertItem?

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let alertItem = alertItem {
                Color.black.opacity(0.2)
                    .overlay(
                        VStack {
                            VStack(spacing: 20) {
                                if let bigIconName = alertItem.bigIconName {
                                    Image(bigIconName)
                                }
                                
                                HStack(alignment: .top, spacing: 5) {
                                    if let smallIconName = alertItem.smallIconName {
                                        Image(smallIconName)
                                    }
                                    
                                    Text(alertItem.title)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                }
                                
                                Text(alertItem.message)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(20)
                            
                            HStack(spacing: 0) {
                                Text(alertItem.button1Title)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .background(alertItem.colorButton1)
                                    .onTapGesture {
                                        close()
                                        alertItem.action1()
                                    }
                                
                                if let buttonTitle = alertItem.button2Title, let action = alertItem.action2 {
                                    Text(buttonTitle)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .background(alertItem.colorButton2)
                                    
                                        .onTapGesture {
                                            close()
                                            action()
                                        }
                                }
                            }
                            .frame(height: 50)
                            .foregroundColor(.white)
                        }
                        .frame(width: 350)
                        .background(Color.white)
                        .cornerRadius(15)
                    ).ignoresSafeArea(.all)
            }
        }
    }
    
    private func close() {
        alertItem = nil
    }
}
