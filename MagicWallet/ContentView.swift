//
//  ContentView.swift
//  MagicWallet
//
//  Created by Anton Udovychenko on 7/10/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NFTGridView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
