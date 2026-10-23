//
//  BeerRowView.swift
//  Zythos
//

import SwiftUI

// A beer on one line: glass, name, brewery and style, the user's mark, and ABV on the right
struct BeerRowView: View {

    let beer: Beer
    // Shown when the row appears outside its brewery's page, e.g. in the Beers catalog
    var breweryName: String? = nil
    // From the user's log, when there is one
    var isTried = false
    var rating: Int? = nil

    var body: some View {
        HStack(spacing: 14) {
            BeerGlassView(beer: beer, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(beer.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(details)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)

                if !beer.localIngredients.isEmpty {
                    Label(beer.localIngredients.joined(separator: ", "), systemImage: "leaf")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let rating {
                StarsLabel(rating: rating)
            } else if isTried {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Δοκιμασμένη")
            }

            if let abv = beer.abvPercent {
                Text(abv)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.accentColor)
                    .frame(minWidth: 44, alignment: .trailing)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    // "Μπύρα Χίου · Pilsner", leaving out the brewery on its own page
    private var details: String {
        [breweryName, beer.style]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

#Preview {
    List(Catalog.bundled.beers) { beer in
        BeerRowView(beer: beer, breweryName: "Ζυθοποιία")
    }
}
