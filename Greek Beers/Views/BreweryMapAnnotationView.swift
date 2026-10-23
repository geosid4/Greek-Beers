//
//  BreweryMapAnnotationView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 12/7/23.
//

import SwiftUI

// The brewery's logo in a white disc, ringed in the accent colour and larger when selected
struct BreweryMapAnnotationView: View {

    let brewery: Brewery
    let isSelected: Bool

    var body: some View {
        logo
            .padding(isSelected ? 6 : 4)
            .frame(width: size, height: size)
            .background(.white, in: .circle)
            .overlay {
                Circle().strokeBorder(Color.accentColor, lineWidth: isSelected ? 3 : 1.5)
            }
            .shadow(color: .black.opacity(0.25), radius: isSelected ? 6 : 3, y: 2)
            .animation(.snappy, value: isSelected)
            .accessibilityLabel(brewery.name)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var size: CGFloat { isSelected ? 52 : 36 }

    @ViewBuilder
    private var logo: some View {
        if let imageName = brewery.imageNames.first {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)
        } else {
            Image(systemName: "mug.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.accentColor)
                .padding(4)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        BreweryMapAnnotationView(brewery: Catalog.bundled.breweries[0], isSelected: false)
        BreweryMapAnnotationView(brewery: Catalog.bundled.breweries[0], isSelected: true)
    }
    .padding()
    .background(.blue.opacity(0.2))
}
