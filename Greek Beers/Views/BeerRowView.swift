//
//  BeerRowView.swift
//  Zythos
//

import SwiftUI

struct BeerRowView: View {

    let beer: Beer

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            colorSwatch

            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                Text(details)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !beer.localIngredients.isEmpty {
                    Label(beer.localIngredients.joined(separator: ", "), systemImage: "leaf")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    // "Pilsner · 5% ABV · 30 IBU", leaving out whatever we don't know
    private var details: String {
        var parts = [beer.style]
        if let abv = beer.abv {
            parts.append("\(abv.formatted(.number.precision(.fractionLength(0...1))))% ABV")
        }
        if let ibu = beer.ibu {
            parts.append("\(ibu) IBU")
        }
        return parts.joined(separator: " · ")
    }

    private var colorSwatch: some View {
        Circle()
            .fill(swatchColor)
            .overlay(Circle().strokeBorder(.secondary.opacity(0.3)))
            .frame(width: 20, height: 20)
            .padding(.top, 2)
            .accessibilityHidden(true)
    }

    private var swatchColor: Color {
        switch beer.color {
        case .pale: Color(red: 0.96, green: 0.80, blue: 0.35)
        case .amber: Color(red: 0.80, green: 0.45, blue: 0.15)
        case .dark: Color(red: 0.25, green: 0.13, blue: 0.08)
        case nil: Color.secondary.opacity(0.2)
        }
    }
}

#Preview {
    List(Catalog.bundled.beers) { beer in
        BeerRowView(beer: beer)
    }
}
