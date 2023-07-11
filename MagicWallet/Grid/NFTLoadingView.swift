//
//  NFTLoadingView.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// Initial view that is shown to a user while we're fetching the data
struct NFTLoadingView: View {
    @State var isAnimating: Bool = true
    
    var body: some View {
        VStack {
            Text("Loading...")
            ActivityIndicator($isAnimating, style: .large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NFTLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        NFTLoadingView()
    }
}
