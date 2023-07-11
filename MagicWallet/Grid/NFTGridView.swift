//
//  NFTGridView.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct Consts {
    static let numberOfRows: Int = 2
    static let padding: CGFloat = 16
    static var itemSize: CGFloat {
        return (UIScreen.main.bounds.size.width - 2 * padding) / CGFloat(numberOfRows)
    }
}

struct NFTGridView: View {
    @ObservedObject
    var viewModel: NFTGridViewModel = .init()
    
    let columns: [GridItem] = .init(repeating: .init(.fixed(Consts.itemSize)), count: Consts.numberOfRows)
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search NFT", text: $viewModel.searchText)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "x.circle")
                    }
                }
            }
            viewForState(viewModel.state)
            .onAppear() {
                viewModel.startObserving()
            }
            .onDisappear() {
                viewModel.stopObserving()
            }
        }
    }
    
    @ViewBuilder
    func viewForState(_ state: NFTGridViewModel.State) -> some View {
        switch state {
        case .empty:
            NFTEmptyView()
        case .loading:
            NFTLoadingView()
        case .error:
            VStack {
                Text("Something went wring =(")
            }
        case .loaded(let items, let hasMore):
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(items, id: \.id) { item in
                        NFTGridItemView(item: item)
                        .onTapGesture {
                            // TODO: handle tap here -> open details
                        }
                    }
                    
                    if hasMore {
                        NFTLoadingMoreView()
                        .onAppear() {
                            // Show more listing as user scrolls down the page
                            viewModel.requestMore()
                        }
                    }
                }
            }
        }
    }
}

// Each card will consist of a gif, name, price.
struct NFTGridItemView : View {
    var item: NFTGridItem
    
    var body: some View {
        ZStack {
            VStack {
                WebImage(url: item.imageURL, options: [.scaleDownLargeImages, .highPriority])
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().foregroundColor(.gray)
                        Text(item.name)
                    }
                    .frame(width: Consts.itemSize, height: Consts.itemSize)
                }
                .indicator(.activity)
                .transition(.fade)
                .scaledToFit()
                .cornerRadius(16)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.name)
                        
                        HStack(alignment: .center) {
                            Image("solana-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            Text(item.price)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .frame(width: Consts.itemSize)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke()
        )
    }
}

struct NFTLoadingMoreView: View {
    @State var isAnimating: Bool = true
    
    var body: some View {
        VStack {
            ActivityIndicator($isAnimating, style: .large)
        }
        .frame(width: Consts.itemSize)
    }
}

struct NFTGridView_Previews: PreviewProvider {
    static var previews: some View {
        NFTGridView()
    }
}
