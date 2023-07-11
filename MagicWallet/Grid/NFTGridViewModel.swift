//
//  NFTGridViewModel.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import Foundation

struct NFTGridItem: Identifiable {
    var id = UUID()
    var imageURL: URL?
    var name: String
    var price: String
}

/// Main class for business logic
class NFTGridViewModel: ObservableObject {
    enum State {
        case empty
        case loading
        case loaded([NFTGridItem], Bool)
        case error
    }
    
    @Published
    var state: State = .loading
    
    @Published
    var searchText: String = "" {
        didSet {
            self.filter(searchText)
        }
    }
    
    private var stateBeforeSearch: State?
    private var isSearching: Bool { stateBeforeSearch != nil }
    
    private let collectionFetcher: CollectionFetcher = .init(networkClient: .init(), collectionNmae: "claynosaurz")
    
    func startObserving() {
        requestMore()
    }
    
    func stopObserving() {
        
    }
    
    // Add a search bar that filter NFTs on client side, only the nfts match the search string should show up
    func filter(_ text: String) {
        if text.isEmpty {
            if let state = self.stateBeforeSearch {
                self.state = state
                self.stateBeforeSearch = nil
            }
            return
        }
        
        if stateBeforeSearch == nil {
            self.stateBeforeSearch = self.state
        }
        switch self.stateBeforeSearch {
        case .loaded(let array, _):
            let filetered = array.filter { $0.name.lowercased().contains(text.lowercased()) }
            if filetered.count == 0 {
                self.state = .empty
            } else {
                self.state = .loaded(filetered, false)
            }
        default:
            break
        }
    }
    
    func requestMore() {
        guard !isSearching else { return }
        Task { @MainActor in
            do {
                let data = try await collectionFetcher.requestMore()
                let newItems = data.map { $0.toNFTGridItem() }
                updateState(newItems, hasMore: newItems.count > 0) // should be resolved by page token, but OK for now
            } catch {
                self.state = .error
            }
        }
    }
    
    private func updateState(_ newItems: [NFTGridItem], hasMore: Bool) {
        guard newItems.count > 0 else {
            switch state {
            case .loaded(let array, _):
                if array.count == 0 {
                    self.state = .empty
                } else {
                    self.state = .loaded(array, false)
                }
            default:
                self.state = .empty
                break
            }
            return
        }
        
        switch self.state {
        case .loaded(let items, _):
            self.state = .loaded(items + newItems, hasMore)
        default:
            self.state = .loaded(newItems, hasMore)
        }
    }
}

extension CollectionItem {
    func toNFTGridItem() -> NFTGridItem {
        var imageURL: URL? = nil
        if let img {
            imageURL = .init(string: img)
        }
        
        let name = title ?? mintAddress
        var priceString = "n/a"
        if let price {
            priceString = "\(price)"
        }
        
        return .init(imageURL: imageURL, name: name, price: priceString)
    }
}
