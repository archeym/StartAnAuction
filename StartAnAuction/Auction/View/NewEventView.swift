//
//  NewEventView.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//
import SwiftUI

struct NewEventView: View {
    
    @State private var navigateToAuctionView: Bool = false

    // Shared ViewModel between screens
    @StateObject private var viewModel = AuctionViewModel(
        manager: AuctionManager(),
        bidFeed: SimulatedBidFeed(),
        config: .init(startingPrice: 0, durationSeconds: 15)
    )

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                // iOS 16+: NavigationStack with programmatic push via navigationDestination
                NavigationStack {
                    content
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.automatic)
                        .navigationDestination(isPresented: $navigateToAuctionView) {
                            AuctionView(viewModel: viewModel)
                        }
                }
            } else {
                // iOS 15 fallback: NavigationView with hidden NavigationLink(isActive:)
                NavigationView {
                    content
                        .navigationBarTitle("New Event", displayMode: .automatic)
                        .background(
                            NavigationLink(
                                destination: AuctionView(viewModel: viewModel),
                                isActive: $navigateToAuctionView
                            ) { EmptyView() }
                            .hidden()
                        )
                }
            }
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    HStack { Text("Please Enter Your Name"); Spacer() }
                    TextField("Name...", text: $viewModel.userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                }

                Button {
                    viewModel.startAuction()
                    navigateToAuctionView = true
                } label: {
                    Label("Start New Auction", systemImage: "star.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.userName.isEmpty)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .modifier(ScrollDismissModifier())
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) }
    }
}
