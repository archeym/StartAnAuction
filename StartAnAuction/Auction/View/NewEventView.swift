//
//  NewEventView.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI
import NetworkMonitor

struct NewEventView: View {

    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var viewModel: AuctionViewModel
    @State private var navigateToAuctionView = false

    private static let defaultService: any MerchantServiceProtocol = APIManager(config: .prod)

    init(service: any MerchantServiceProtocol = NewEventView.defaultService) {
        let fetcher = MerchantFetcher(service: service)
        _viewModel = StateObject(
            wrappedValue: AuctionViewModel(
                manager: AuctionManager(),
                bidFeed: SimulatedBidFeed(),
                config: .init(startingPrice: 0, durationSeconds: 15),
                merchantFetcher: fetcher
            )
        )
    }

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
        .task { // Load merchants on appear using Swift concurrency
            await viewModel.loadMerchantsOnAppear()
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
                if viewModel.isLoading {
                    ProgressView("Loading merchants…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if !viewModel.merchants.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Merchants")
                            .font(.headline)
                        ForEach(viewModel.merchants) { merchant in
                            Text(merchant.name ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityIdentifier("merchant_\(String(describing: merchant.id))")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

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
                .accessibilityIdentifier("startAuctionButton")

                Spacer(minLength: 24)
            }
            .padding()
            .padding(.horizontal, UIDevice.isIPad ? 50 : 10)
        }
        .modifier(ScrollDismissModifier())
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) }
        .refreshable { // Pull-to-refresh
            await viewModel.refreshMerchants()
        }
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
