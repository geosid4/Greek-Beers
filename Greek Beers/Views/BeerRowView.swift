//
//  BeerRowView.swift
//  Zythos
//

import SwiftUI

struct BeerRowView: View {

    let beer: Beer
    // Shown when the row appears outside its brewery's page, e.g. in the Beers catalog
    var breweryName: String? = nil
    // From the user's log, when there is one
    var isTried = false
    var rating: Int? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            BeerGlassView(beer: beer, height: 34)

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

            if let rating {
                StarsLabel(rating: rating)
                    .padding(.top, 4)
            } else if isTried {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .padding(.top, 2)
                    .accessibilityLabel("Δοκιμασμένη")
            }
        }
        .accessibilityElement(children: .combine)
    }

    // "Μπύρα Χίου · Pilsner · 5% ABV · 18–22 IBU", leaving out whatever we don't know
    private var details: String {
        [breweryName, beer.style, beer.formattedABV, beer.formattedIBU]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

#Preview {
    List(Catalog.bundled.beers) { beer in
        BeerRowView(beer: beer, breweryName: "Ζυθοποιία")
    }
}
