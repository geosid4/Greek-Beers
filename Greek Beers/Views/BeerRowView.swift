//
//  BeerRowView.swift
//  Zythos
//

import SwiftUI

struct BeerRowView: View {

    let beer: Beer
    // Shown when the row appears outside its brewery's page, e.g. in the Beers catalog
    var breweryName: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            BeerColorSwatch(beer: beer, size: 20)
                .padding(.top, 2)

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

    // "Μπύρα Χίου · Pilsner · 5% ABV · 30 IBU", leaving out whatever we don't know
    private var details: String {
        var parts = [breweryName, beer.style, beer.formattedABV].compactMap { $0 }
        if let ibu = beer.ibu {
            parts.append("\(ibu) IBU")
        }
        return parts.joined(separator: " · ")
    }
}

struct BeerColorSwatch: View {

    let beer: Beer
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(beer.displayColor)
            .overlay(Circle().strokeBorder(.secondary.opacity(0.3)))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

extension Beer {

    var formattedABV: String? {
        abv.map { "\($0.formatted(.number.precision(.fractionLength(0...1))))% ABV" }
    }

    var displayColor: Color {
        switch color {
        case .pale: Color(red: 0.96, green: 0.80, blue: 0.35)
        case .amber: Color(red: 0.80, green: 0.45, blue: 0.15)
        case .dark: Color(red: 0.25, green: 0.13, blue: 0.08)
        case nil: Color.secondary.opacity(0.2)
        }
    }
}

#Preview {
    List(Catalog.bundled.beers) { beer in
        BeerRowView(beer: beer, breweryName: "Ζυθοποιία")
    }
}
