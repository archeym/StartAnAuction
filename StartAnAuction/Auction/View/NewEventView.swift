//
//  NewEventView.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//
import SwiftUI
import NetworkMonitor

struct NewEventView: View {

    @State private var navigateToAuctionView: Bool = false
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // Shared ViewModel between screens
    @StateObject private var viewModel = AuctionViewModel(
        manager: AuctionManager(),
        bidFeed: SimulatedBidFeed(),
        config: .init(startingPrice: 0, durationSeconds: 15)
    )

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    content
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.automatic)
                        .navigationDestination(isPresented: $navigateToAuctionView) {
                            AuctionView(viewModel: viewModel)
                                .accessibilityIdentifier("auctionScreenRoot")
                        }
                }
            } else {
                NavigationView {
                    content
                        .navigationBarTitle("New Event", displayMode: .automatic)
                        .background(
                            NavigationLink(
                                destination: AuctionView(viewModel: viewModel)
                                    .accessibilityIdentifier("auctionScreenRoot"),
                                isActive: $navigateToAuctionView
                            ) { EmptyView() }
                            .hidden()
                        )
                }
            }
        }
        .alertWith($viewModel.alertItem)
        .disabled(!(networkMonitor.isConnected || ProcessInfo.processInfo.arguments.contains("UITESTS")))
        .onChange(of: networkMonitor.isConnected) { newValue in
            if !newValue {
                viewModel.alertItem = AlertItem(
                    title: "The device is currently offline!",
                    message: "Make sure the device is connected to the network.",
                    button1Title: "OK",
                    action1: {}
                )
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                nameFieldView

                Button {
                    viewModel.startAuction()
                    navigateToAuctionView = true
                } label: {
                    Label("Start New Auction", systemImage: "star.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(viewModel.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("startAuctionButton")

                Spacer(minLength: 24)
            }
            .padding()
            .padding(.horizontal, UIDevice.isIPad ? 50 : 10)
        }
        .modifier(ScrollDismissModifier())
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) }
    }

    private var nameFieldView: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 2){
                Text("Please Enter Your Name")
                Text("*").foregroundColor(.red)
            }
            .modifier(ForTextFieldViewModifier())

            CharacterTextField(
                placeholder: "",
                textAlignmentCenter: .right,
                keyboardType: .default,
                text: $viewModel.userName,
                onEditingChanged: { _ in }
            )
            .modifier(ForNamePhoneTextFieldViewModifier())
            .offset(y: 5)
            .accessibilityIdentifier("userNameField")
        }
        .modifier(TextFieldViewModifier())
    }
}
