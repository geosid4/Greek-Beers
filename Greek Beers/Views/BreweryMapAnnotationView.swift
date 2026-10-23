//
//  BreweryMapAnnotationView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 12/7/23.
//

import SwiftUI

struct BreweryMapAnnotationView: View {

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mug.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundStyle(.white)
                .padding(6)
                .background(Color.accentColor, in: .circle)

            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.accentColor)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
                .padding(.bottom, 40)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BreweryMapAnnotationView()
    }
}
