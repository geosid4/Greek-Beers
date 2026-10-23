//
//  BeerCardView.swift
//  Zythos
//

import SwiftUI

// A beer as a card: glass, name, brewery and ABV, with the user's stars when there are some
struct BeerCardView: View {

    let beer: Beer
    let brewery: Brewery?
    var isTried = false
    var rating: Int? = nil

    var body: some View {
        HStack(spacing: 14) {
            BeerGlassView(beer: beer, height: 64)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(beer.name)
                    .font(.headline)
                    .lineLimit(2)

                if let brewery {
                    HStack(spacing: 6) {
                        BreweryLogoView(brewery: brewery, size: 20)
                        Text(brewery.name)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Badge(text: beer.style)
                    if let abv = beer.formattedABV {
                        Badge(text: abv)
                    }
                    if !beer.localIngredients.isEmpty {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityLabel("Ελληνικά υλικά")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let rating {
                StarsLabel(rating: rating)
            } else if isTried {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityLabel("Δοκιμασμένη")
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .contentShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

// The tall card in the "Με ελληνικά υλικά" carousel
struct LocalBeerCardView: View {

    let beer: Beer
    let brewery: Brewery?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BeerGlassView(beer: beer, height: 80)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(beer.displayColor.opacity(0.15), in: .rect(cornerRadius: 14))

            Text(beer.name)
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
            if let brewery {
                Text(brewery.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Label(beer.localIngredients.joined(separator: ", "), systemImage: "leaf.fill")
                .font(.caption)
                .foregroundStyle(.green)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 170)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .contentShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

struct Badge: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.secondary.opacity(0.12), in: .capsule)
    }
}

#Preview {
    let catalog = Catalog.bundled
    return ScrollView {
        VStack(spacing: 10) {
            ForEach(catalog.beers) { beer in
                BeerCardView(beer: beer, brewery: catalog.breweries.first { $0.id == beer.breweryId },
                             isTried: true, rating: 4)
            }
            LocalBeerCardView(beer: catalog.beers[4], brewery: catalog.breweries[2])
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
