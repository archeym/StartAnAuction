//
//  ContentView.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 15/08/2025.
//

import SwiftUI

struct AuctionView: View {
    
    @ObservedObject var viewModel: AuctionViewModel
    
    var body: some View {
        VStack(spacing: 25) {
            Group {
                HStack {
                    Text("Time remaining:")
                    Spacer()
                    ///Smooth mm:ss.SS countdown updated by TimelineView
                    if viewModel.isRunning {
                        TimelineView(.periodic(from: .now, by: 1.0 / 60.0)) { context in
                            let ms = viewModel.computeRemainingMilliseconds(now: context.date, endDate: viewModel.endDate)
                            Text(TimeFormatter.mmssSS(milliseconds: ms)).monospacedDigit().font(.title2)
                        }
                    } else {
                        Text(TimeFormatter.mmssSS(milliseconds: 0)).monospacedDigit().font(.title2)
                    }
                }
            }
            
            Group {
                HStack {
                    Text("Current price:")
                    Spacer()
                    Text(viewModel.currentPriceText).font(.title3).bold()
                }
                HStack {
                    Text(viewModel.currentWinnerText)
                    Spacer()
                }
            }
            
            Group {
                
                bidInputView
                
                Button {
                    viewModel.placeUserBid()
                } label: {
                    Label("Place Bid", systemImage: "hand.rays.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(!viewModel.isRunning || !viewModel.isAmountHigher)
            }
            
            Spacer()
        }
        .padding()
        .padding(.horizontal, UIDevice.isIPad ? 50: 10)
        .navigationBarTitle("Auction is ON!", displayMode: .automatic)
        .onDisappear {
            viewModel.bidInput = "0.00"
        }
    }
    
    private var bidInputView: some View {
        ZStack(alignment: .leading) {
            HStack {
                Text("Your bid:")
            }.modifier(ForTextFieldViewModifier())

            DecimalCurrencyTextField(
                placeholder: "0.00",
                textAlignment: .right,
                keyboardType: .decimalPad,
                shouldOpenKeyboard: false,
                text: $viewModel.bidInput,
                onEditingChanged: { _ in }
            )
            .id(viewModel.bidInputResetID)
            .modifier(DecimalStyleTextFieldViewModifier())
        }
        .padding(.top, 2)
        .modifier(TextFieldViewModifier())
    }
}
