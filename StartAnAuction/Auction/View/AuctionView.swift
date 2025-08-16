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
        VStack(spacing: 16) {
            
            Group {
                
                HStack {
                    Text("Time remaining")
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
                HStack {
                    Text("Your bid:")
                    Spacer()
                    TextField("Amount", text: $viewModel.bidInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 160)
                }
                Button(action: viewModel.placeUserBid) {
                    Text("Place Bid").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isRunning || viewModel.bidInput.isEmpty)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Auction is ON!", displayMode: .automatic)
    }
}
