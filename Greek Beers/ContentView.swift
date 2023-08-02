//
//  ContentView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            Text("Greek Beers")
                .foregroundColor(.white)
                .font(.system(size: 30))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
