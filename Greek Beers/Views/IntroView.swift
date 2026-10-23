//
//  IntroView.swift
//  Greek Beers
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
            LocationsView()
        } else {
            VStack {
                Image("beer")
                Text("Beers in Greece")
                    .font(.custom("Baskerville-Bold", size: 40))
                    .foregroundStyle(.primary.opacity(0.8))
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
        .environment(LocationsViewModel())
}
