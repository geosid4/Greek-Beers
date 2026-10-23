//
//  IntroView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

struct IntroView: View {
    @State private var isActive = false
    @State private var size = 0.2
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            RootView()
        } else {
            VStack {
                Image("beer")
                Text("Zythos")
                    .font(.custom("Baskerville-Bold", size: 56))
                    .foregroundStyle(.primary.opacity(0.8))
                Text("Greek Beer Guide")
                    .font(.custom("Baskerville", size: 28))
                    .foregroundStyle(.secondary)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    size = 0.5
                    opacity = 1.0
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(2))
                isActive = true
            }
        }
    }
}

#Preview {
    IntroView()
        .environment(BreweriesViewModel())
        .environment(BeersViewModel())
        .environment(AppRouter())
        .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}
