//
//  NFTEmptyView.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import SwiftUI

/// Represents the empty state(0 items in response or 0 items from Search)
struct NFTEmptyView: View {
    var body: some View {
        VStack {
            Text("Sorry, nothing to see here")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NFTEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        NFTEmptyView()
    }
}
