//
//  NetworkClient.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import Foundation

struct CollectionItem: Codable {
    var mintAddress: String
    var price: CGFloat?
    var title: String?
    var img: String?
}

struct CollectionItemResponse: Codable {
    var results: [CollectionItem]
}

class NetworkClient {
    enum NetworkClientError: Error {
        case badAPI
    }
    
    private let apiPath: String
    private let session: URLSession
    private let decoder: JSONDecoder = .init()
    private let retryCount: Int
    
    init(apiPath: String = "https://api-mainnet.magiceden.io/idxv2/getListedNftsByCollectionSymbol", urlSession: URLSession = .shared, retryCount: Int = 3) {
        self.apiPath = apiPath
        self.session = urlSession
        self.retryCount = retryCount
    }
    
    func requestCollection(_ collection: String, limit: Int = 20, offset: Int = 0) async throws -> [CollectionItem] {
        guard var urlComponents = URLComponents(string: apiPath) else { throw NetworkClientError.badAPI }
        
        urlComponents.queryItems = [
            .init(name: "collectionSymbol", value: collection),
            .init(name: "limit", value: String(limit)),
            .init(name: "offset", value: String(offset))
        ]
        
        guard let url = urlComponents.url else { throw NetworkClientError.badAPI }
        
        print("Start requesting items from \(url.absoluteString)")
        // Retry on api failure since it’s public faced and have rate limit
        for attempt in 0..<retryCount {
            do {
                return try await retrieveData(url: url)
            } catch {
                print("Got an error, will retry. Attempt #\(attempt)")
                continue
            }
        }

        // The final attempt
        let result = try await retrieveData(url: url)
        print("Got \(result.count) items")
        return result
    }
    
    private func retrieveData(url: URL) async throws -> [CollectionItem] {
        let (data, _) = try await session.data(from: url)
        return try decoder.decode(CollectionItemResponse.self, from: data).results
    }
}
