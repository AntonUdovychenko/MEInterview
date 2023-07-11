//
//  CollectionFetcher.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import Foundation

class CollectionFetcher {
    private let networkClient: NetworkClient
    private let collectionNmae: String
    private var currentPage: Int = 0
    
    init(networkClient: NetworkClient, collectionNmae: String) {
        self.networkClient = networkClient
        self.collectionNmae = collectionNmae
    }
    
    func requestMore() async throws -> [CollectionItem] {
        do {
            let data = try await networkClient.requestCollection(collectionNmae, limit: 20, offset: currentPage *  20)
            currentPage += 1
            return data
        } catch {
            print(error)
        }
        
        return []
    }
}
