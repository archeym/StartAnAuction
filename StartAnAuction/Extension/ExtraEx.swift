//
//  ExtraEx.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 16/08/2025.
//

import SwiftUI

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}


var screenSize: CGSize {
#if os(iOS)
    return UIScreen.main.bounds.size
#else
    return NSScreen.main?.frame.size ?? .zero
#endif
}
