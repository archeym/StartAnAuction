//
//  StartAnAuctionApp.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI
import NetworkMonitor

@main
struct StartAnAuctionApp: App {
    
    private var networkMonitor = NetworkMonitor()
    
    var body: some Scene {
        WindowGroup {
            NewEventView()
                .environmentObject(networkMonitor)
        }
    }
}
